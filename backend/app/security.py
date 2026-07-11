import hashlib
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
import bcrypt
from jose import JWTError, jwt
from sqlalchemy import select
from sqlalchemy.orm import Session

from .config import settings
from .database import get_db
from .models import RefreshToken, User

_bearer = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(plain.encode(), hashed.encode())
    except ValueError:
        return False


def create_access_token(user_id: int) -> str:
    expires = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_expire_minutes
    )
    payload = {"sub": str(user_id), "exp": expires}
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)


def _hash_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode()).hexdigest()


def _as_utc(value: datetime) -> datetime:
    """SQLite doesn't reliably round-trip tzinfo, so normalize before
    comparing datetimes read back from the database."""
    return value if value.tzinfo is not None else value.replace(tzinfo=timezone.utc)


def create_refresh_token(user_id: int, db: Session) -> str:
    raw_token = secrets.token_urlsafe(48)
    expires_at = datetime.now(timezone.utc) + timedelta(
        days=settings.refresh_token_expire_days
    )
    record = RefreshToken(
        user_id=user_id,
        token_hash=_hash_token(raw_token),
        expires_at=expires_at,
    )
    db.add(record)
    db.commit()
    return raw_token


def verify_and_rotate_refresh_token(
    raw_token: str, db: Session
) -> tuple[str, str, User]:
    """Validates a refresh token, rotates it, and returns
    (new_access_token, new_refresh_token, user)."""
    unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired refresh token",
    )
    token_hash = _hash_token(raw_token)
    record = db.scalar(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    )
    now = datetime.now(timezone.utc)
    if record is None or record.revoked_at is not None or _as_utc(record.expires_at) < now:
        raise unauthorized

    user = db.get(User, record.user_id)
    if user is None:
        raise unauthorized

    record.revoked_at = now
    db.add(record)

    new_access_token = create_access_token(user.id)
    new_refresh_token = create_refresh_token(user.id, db)

    db.commit()
    return new_access_token, new_refresh_token, user


def revoke_refresh_token(raw_token: str, db: Session) -> None:
    token_hash = _hash_token(raw_token)
    record = db.scalar(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    )
    if record is not None and record.revoked_at is None:
        record.revoked_at = datetime.now(timezone.utc)
        db.add(record)
        db.commit()


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User:
    unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Not authenticated",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if credentials is None:
        raise unauthorized
    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.secret_key,
            algorithms=[settings.algorithm],
        )
        user_id = int(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise unauthorized

    user = db.get(User, user_id)
    if user is None:
        raise unauthorized
    return user
