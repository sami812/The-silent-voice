from pydantic import BaseModel, Field
from typing import List, Optional

class SignRequest(BaseModel):
    words: List[str] = Field(..., description="List of disconnected English words detected from sign language")
    location: Optional[str] = Field(default=None, description="Optional location context (e.g., Pharmacy, Street)")

class SignResponse(BaseModel):
    translated_text: str
    suggested_replies: List[str]
    context_type: str 
    is_emergency: bool = Field(default=False, description="Flag for emergency or dangerous situations")
    whatsapp_msg: str = Field(default="", description="Ready-to-send Arabic distress message")

class TextRequest(BaseModel):
    text: str = Field(..., description="Sentence spoken by the hearing person")
    location: Optional[str] = Field(default=None, description="Optional location context")

class TextResponse(BaseModel):
    suggested_replies: List[str]