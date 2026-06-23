from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from api.schemas import SignRequest, SignResponse, TextRequest, TextResponse, SummaryRequest, SummaryResponse
from agents.interpreter_agent import translate_signs_agent, suggest_replies_for_deaf_agent, summarize_chat_agent

app = FastAPI(
    title="The Silent Voice API",
    description="Backend service for processing sign language and generating smart replies.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"], 
)

@app.post("/api/process-signs", response_model=SignResponse)
async def process_signs(request: SignRequest):
    try:
        # Pass both words and the optional location to the agent
        result = translate_signs_agent(words=request.words, location=request.location)
        
        return SignResponse(
            translated_text=result["translated_text"],
            suggested_replies=result["suggested_replies"],
            context_type=result.get("context_type", "Normal"),
            is_emergency=result.get("is_emergency", False),
            whatsapp_msg=result.get("whatsapp_msg", "")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

@app.post("/api/suggest-replies", response_model=TextResponse)
async def suggest_replies(request: TextRequest):
    try:
        # Pass text and the optional location to the agent
        result = suggest_replies_for_deaf_agent(text=request.text, location=request.location)
        
        return TextResponse(
            suggested_replies=result["suggested_replies"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")
@app.post("/api/summarize", response_model=SummaryResponse)
async def summarize_chat(request: SummaryRequest):
    try:
        # Pass the chat history array to the summarization agent
        result = summarize_chat_agent(chat_history=request.chat_history)
        
        return SummaryResponse(
            summary=result["summary"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")
    
    
@app.get("/")
async def root():
    return {"status": "ok", "message": "The Silent Voice API is running successfully."}