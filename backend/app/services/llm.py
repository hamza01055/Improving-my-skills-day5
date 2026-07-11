from openai import OpenAI

from ..config import settings

_client = (
    OpenAI(api_key=settings.groq_api_key, base_url="https://api.groq.com/openai/v1")
    if settings.groq_api_key
    else None
)

_SYSTEM_PROMPT = (
    "You are the AI assistant inside Second Brain, a personal knowledge and "
    "productivity app. Be concise, helpful, and friendly."
)


def generate_reply(messages: list[dict]) -> str:
    """Produce an assistant reply for a chat history.

    Uses Groq's OpenAI-compatible chat completions API when GROQ_API_KEY is
    configured; falls back to a stub echo otherwise. `messages` is a list of
    {"role", "content"} dicts, oldest first.
    """
    if _client is None:
        last_user_message = next(
            (m["content"] for m in reversed(messages) if m["role"] == "user"),
            "",
        )
        return (
            "AI replies will go live once an API key is configured — "
            f"here's what you said: {last_user_message}"
        )

    completion = _client.chat.completions.create(
        model=settings.groq_model,
        messages=[{"role": "system", "content": _SYSTEM_PROMPT}, *messages],
    )
    return completion.choices[0].message.content or ""
