import sys
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# Fix path issues
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import our AI Brain
from agents.interpreter_agent import InterpreterAgent

app = FastAPI(title="Sign Language Backend API")

# --- CORS Setup (CRITICAL FOR FLUTTER) ---
# This allows the Flutter app to send requests to this API without security blocks
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins (change to specific domains in production)
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (POST, GET, etc.)
    allow_headers=["*"],  # Allows all headers
)

# Initialize the agent
interpreter = InterpreterAgent()

# Expected data structure
class SignPayload(BaseModel):
    user_id: str
    user_type: str           
    signs: list[str]         
    location: str = "unknown"
    is_moving: bool = False

@app.post("/api/process")
async def process_signs(payload: SignPayload):
    print(f"--> Received signs from {payload.user_id}: {payload.signs}")
    
    context = {
        "location": payload.location,
        "is_moving": payload.is_moving
    }
    
    # Process with Groq AI
    final_text = interpreter.translate(payload.signs, context)

    # Determine UI response
    display_mode = "avatar" if payload.user_type in ["deaf", "deaf_mute"] else "text"
    
    return {
        "status": "success",
        "display_mode": display_mode,
        "message": final_text
    }

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)