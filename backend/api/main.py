from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

# Import schemas and agent functions
from api.schemas import SignRequest, SignResponse, TextRequest, TextResponse
from agents.interpreter_agent import translate_signs_agent, suggest_replies_for_deaf_agent

# Initialize FastAPI application
app = FastAPI(
    title="The Silent Voice API",
    description="Backend service for processing sign language and generating smart replies.",
    version="1.0.0"
)

# Configure CORS (Cross-Origin Resource Sharing)
# This is crucial for allowing the Flutter app to communicate with this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allows all headers
)

@app.post("/api/process-signs", response_model=SignResponse)
async def process_signs(request: SignRequest):
    """
    Endpoint to process disconnected sign language words.
    Returns a full sentence and 4 suggested replies.
    """
    try:
        result = translate_signs_agent(request.words)
        return SignResponse(
            translated_text=result["translated_text"],
            suggested_replies=result["suggested_replies"],
            context_type=result.get("context_type", "Normal")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

@app.post("/api/suggest-replies", response_model=TextResponse)
async def suggest_replies(request: TextRequest):
    """
    Endpoint to process a hearing person's text message.
    Returns 4 suggested replies for the deaf user.
    """
    try:
        result = suggest_replies_for_deaf_agent(request.text)
        return TextResponse(
            suggested_replies=result["suggested_replies"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

# Health check endpoint to verify server is running
@app.get("/")
async def root():
    return {"status": "ok", "message": "The Silent Voice API is running successfully."}