<div align="center">

# IntelliVault — Your AI Second Brain

[![Flutter](https://img.shields.io/badge/Flutter-Material%203-02569B?style=flat-square&logo=flutter)](https://flutter.dev/)
[![FastAPI](https://img.shields.io/badge/FastAPI-Python-009688?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-SQLAlchemy-336791?style=flat-square&logo=postgresql)](https://postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-Cache-DC382D?style=flat-square&logo=redis)](https://redis.io/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker)](https://docker.com/)

*An AI-powered productivity app: chat with your documents, capture notes, manage tasks, and talk to your knowledge — built as a portfolio project showcasing production-grade Flutter + FastAPI + AI engineering.*

[Overview](#overview) · [Architecture](#architecture) · [Getting Started](#getting-started) · [Auth Flow](#auth-flow) · [Roadmap](#roadmap) · [API Reference](#api-reference)

</div>

---

## Overview

IntelliVault is a full-stack "second brain" — a single place to store what you know and an AI layer to retrieve, summarize, and act on it. Upload documents and ask questions against them (RAG), capture notes with AI rewrite and translation, manage tasks with AI-suggested priorities, and interact by voice.

The project is structured as a monorepo with two apps:

```
intellivault/
├── app/        Flutter client (Riverpod · GoRouter · Dio · Hive · Material 3)
└── backend/    FastAPI server (JWT auth · SQLAlchemy · PostgreSQL/SQLite · Docker)
```

---

## Architecture

```
Presentation (screens/widgets)
        ↓
State (Riverpod Notifiers)
        ↓
Repository (business rules)
        ↓
ApiClient (Dio + token interceptor)
        ↓
FastAPI  →  LLM + RAG (Phase 2+)  →  PostgreSQL / Redis
```

The client follows a feature-first clean architecture: each feature lives in `app/lib/features/<name>/` with its own `data / providers / presentation` layers. Shared infrastructure (theme, routing, networking, storage, widgets) lives in `app/lib/core/`.

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Python 3.11+
- Docker Desktop (optional, for the full PostgreSQL + Redis stack)

### Running the Backend

```bash
cd backend
cp .env.example .env            # set a real SECRET_KEY
pip install -r requirements.txt
uvicorn app.main:app --reload   # http://localhost:8000/docs
```

Or with Docker (PostgreSQL + Redis included):

```bash
docker compose up --build
```

> SQLite is used automatically in local development; set `DATABASE_URL` in `.env` to use PostgreSQL.

### Running the App

```bash
cd app
flutter pub get
flutter run
```

The app targets `http://10.0.2.2:8000` by default (Android emulator → host machine). For a physical device or other environments, pass the API base URL explicitly:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000
```

### Running Tests

```bash
cd app
flutter test
```

---

## Auth Flow

On launch, the Splash screen restores the session from secure storage, and GoRouter redirects based on the resulting auth state:

| Auth state | Destination |
|------------|-------------|
| Unknown | Stays on Splash |
| Unauthenticated | Onboarding (first launch) or Login |
| Authenticated | Home dashboard |

Tokens are JWTs issued by the backend, stored with `flutter_secure_storage`, and attached to every request by a Dio interceptor.

---

## Roadmap

- [x] **Phase 1 — Foundation:** clean architecture, Material 3 theme (light/dark, violet-blue gradient, glass cards), GoRouter with auth guards, full email auth (register / login / forgot password / session restore), FastAPI backend with JWT, Docker
- [ ] **Phase 2 — AI Chat:** streaming chat UI, markdown + code highlighting, chat history, LangChain backend
- [ ] **Phase 3 — Knowledge:** document upload (PDF/DOCX/TXT), RAG Q&A, AI summaries, notes with AI rewrite/translate, tasks with AI priorities
- [ ] **Phase 4 — Voice & Offline:** speech-to-text, TTS, Hive offline cache, push notifications, Google sign-in
- [ ] **Phase 5 — Ship:** tests, CI/CD, performance passes, Play Store release

---

## API Reference

**Phase 1 endpoints:**

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/auth/register` | Create account, returns JWT + user |
| `POST` | `/auth/login` | Sign in, returns JWT + user |
| `POST` | `/auth/forgot-password` | Request a reset link (stub) |
| `GET` | `/auth/me` | Current user (Bearer token) |
| `GET` | `/health` | Liveness check |

Interactive Swagger docs are available at `/docs` while the server is running.

---

## Security Notes

- Never commit your `.env` file — use `.env.example` as a template and always set a strong `SECRET_KEY` in production.
- JWTs are stored in `flutter_secure_storage` (Keychain / Keystore), never in plain shared preferences.
