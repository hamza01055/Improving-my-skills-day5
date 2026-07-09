# AI Second Brain

An AI-powered productivity app: chat with your documents, capture notes, manage tasks, and talk to your knowledge — built as a portfolio project showcasing production-grade Flutter + FastAPI + AI engineering.

```
ai_second_brain/
├── app/        Flutter client (Riverpod · GoRouter · Dio · Hive · Material 3)
└── backend/    FastAPI server (JWT auth · SQLAlchemy · PostgreSQL/SQLite · Docker)
```

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

Each feature lives in `app/lib/features/<name>/` with its own `data / providers / presentation` layers. Shared infrastructure (theme, routing, networking, storage, widgets) lives in `app/lib/core/`.

## Running the backend

```bash
cd backend
cp .env.example .env            # set a real SECRET_KEY
pip install -r requirements.txt
uvicorn app.main:app --reload   # http://localhost:8000/docs
```

Or with Docker (Postgres + Redis included):

```bash
docker compose up --build
```

SQLite is used automatically in local dev; set `DATABASE_URL` for Postgres.

## Running the app

```bash
cd app
flutter pub get
flutter run
```

The app targets `http://10.0.2.2:8000` by default (Android emulator → host machine).
For a physical device or other environments:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8000
```

Run tests with `flutter test`.

## Auth flow

Splash restores the session from secure storage → GoRouter redirects based on auth state:

- unknown → stays on Splash
- unauthenticated → Onboarding (first launch) or Login
- authenticated → Home dashboard

Tokens are JWTs issued by the backend, stored with `flutter_secure_storage`, and attached to every request by a Dio interceptor.

## Roadmap

- [x] **Phase 1 — Foundation**: clean architecture, Material 3 theme (light/dark, violet-blue gradient, glass cards), GoRouter with auth guards, full email auth (register / login / forgot password / session restore), FastAPI backend with JWT, Docker
- [ ] **Phase 2 — AI Chat**: streaming chat UI, markdown + code highlighting, chat history, LangChain backend
- [ ] **Phase 3 — Knowledge**: document upload (PDF/DOCX/TXT), RAG Q&A, AI summaries, notes with AI rewrite/translate, tasks with AI priorities
- [ ] **Phase 4 — Voice & offline**: speech-to-text, TTS, Hive offline cache, push notifications, Google sign-in
- [ ] **Phase 5 — Ship**: tests, CI/CD, performance passes, Play Store release

## API (Phase 1)

| Method | Path                    | Description                          |
|--------|-------------------------|--------------------------------------|
| POST   | `/auth/register`        | Create account, returns JWT + user   |
| POST   | `/auth/login`           | Sign in, returns JWT + user          |
| POST   | `/auth/forgot-password` | Request a reset link (stub)          |
| GET    | `/auth/me`              | Current user (Bearer token)          |
| GET    | `/health`               | Liveness check                       |

Interactive docs at `/docs` when the server is running.
