from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import ChatMessage, User
from ..schemas import ChatMessageOut, ChatMessageRequest, ChatReplyResponse
from ..security import get_current_user
from ..services.llm import generate_reply

router = APIRouter(prefix="/chat", tags=["chat"])


@router.get("/history", response_model=list[ChatMessageOut])
def get_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    messages = db.scalars(
        select(ChatMessage)
        .where(ChatMessage.user_id == current_user.id)
        .order_by(ChatMessage.created_at.asc())
    )
    return list(messages)


@router.post("", response_model=ChatReplyResponse)
def send_message(
    body: ChatMessageRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    user_message = ChatMessage(
        user_id=current_user.id, role="user", content=body.content
    )
    db.add(user_message)
    db.commit()
    db.refresh(user_message)

    history = db.scalars(
        select(ChatMessage)
        .where(ChatMessage.user_id == current_user.id)
        .order_by(ChatMessage.created_at.asc())
    )
    reply_text = generate_reply(
        [{"role": m.role, "content": m.content} for m in history]
    )

    assistant_message = ChatMessage(
        user_id=current_user.id, role="assistant", content=reply_text
    )
    db.add(assistant_message)
    db.commit()
    db.refresh(assistant_message)

    return ChatReplyResponse(
        user_message=user_message, assistant_message=assistant_message
    )
