from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import Base, engine
from .routers import auth

# Phase 1: create tables on startup. Later phases switch to Alembic migrations.
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="AI Second Brain API",
    version="0.1.0",
    description="Backend for the AI Second Brain app. Phase 1: authentication.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten before production
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)


@app.get("/health", tags=["meta"])
def health():
    return {"status": "ok"}
