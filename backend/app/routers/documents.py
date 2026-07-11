import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..config import settings
from ..database import get_db
from ..models import Document, User
from ..schemas import DocumentOut
from ..security import get_current_user

router = APIRouter(prefix="/documents", tags=["documents"])

UPLOAD_DIR = Path(settings.upload_dir)
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


def _get_owned_document(document_id: int, db: Session, current_user: User) -> Document:
    document = db.get(Document, document_id)
    if document is None or document.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Document not found"
        )
    return document


@router.get("", response_model=list[DocumentOut])
def list_documents(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    documents = db.scalars(
        select(Document)
        .where(Document.user_id == current_user.id)
        .order_by(Document.created_at.desc())
    )
    return list(documents)


@router.post("/upload", response_model=DocumentOut, status_code=status.HTTP_201_CREATED)
async def upload_document(
    file: UploadFile,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    contents = await file.read()
    stored_name = f"{current_user.id}_{uuid.uuid4().hex}_{file.filename}"
    storage_path = UPLOAD_DIR / stored_name
    storage_path.write_bytes(contents)

    document = Document(
        user_id=current_user.id,
        filename=file.filename or stored_name,
        content_type=file.content_type or "application/octet-stream",
        size_bytes=len(contents),
        storage_path=str(storage_path),
    )
    db.add(document)
    db.commit()
    db.refresh(document)
    return document


@router.delete("/{document_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_document(
    document_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    document = _get_owned_document(document_id, db, current_user)
    storage_path = Path(document.storage_path)
    if storage_path.exists():
        storage_path.unlink()
    db.delete(document)
    db.commit()
