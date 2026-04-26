from pydantic import BaseModel, Field
from typing import List

class SignRequest(BaseModel):
    """Payload received from the Flutter app containing detected sign words."""
    words: List[str] = Field(
        ..., 
        description="A list of disconnected English words detected from sign language"
    )

class SignResponse(BaseModel):
    """Payload sent back to the app with the translation and suggestions."""
    translated_text: str
    suggested_replies: List[str]
    context_type: str 

class TextRequest(BaseModel):
    """Payload received when a hearing person sends a text/voice message."""
    text: str = Field(..., description="The sentence spoken by the hearing person")

class TextResponse(BaseModel):
    """Payload containing suggested replies for the deaf person."""
    suggested_replies: List[str]