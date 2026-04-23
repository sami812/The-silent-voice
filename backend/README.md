# Sign Language AI Copilot - Backend API

## Project Overview
This repository contains the backend API for the Sign Language Copilot system. The system uses a Hybrid Edge-Cloud architecture to ensure speed and privacy.

The mobile application processes video locally to detect isolated sign language words. This cloud API receives those isolated words and uses the Groq AI engine (Llama-3 model) to convert them into natural, grammatically correct sentences in real-time.

## Technology Stack
* Web Framework: FastAPI
* AI Provider: Groq API (Using LPU for low latency)
* AI Model: llama-3.3-70b-versatile
* Cloud Hosting: Render

## API Documentation


### 🌍 Live Environment (Online)
* **API Base URL:** `https://the-silent-voice-xxxx.onrender.com`
* **Live Swagger Docs:** `https://the-silent-voice-xxxx.onrender.com/docs`

### Endpoint
`POST /api/process`
### Endpoint
POST /api/process

### Request Headers
Content-Type: application/json

### Request Payload
The mobile application should send the detected words and the user's context in this format:

{
  "user_id": "user_123",
  "user_type": "deaf",
  "signs": ["hospital", "where", "now"],
  "location": "street",
  "is_moving": true
}

### Response Payload
The API will return the translated sentence and the recommended UI display mode.

{
  "status": "success",
  "display_mode": "avatar",
  "message": "I am heading to the hospital now, but I am not sure where it is."
}

## Local Setup Instructions

1. Clone the repository:
git clone https://github.com/sami812/The-silent-voice.git
cd The-silent-voice/backend

2. Install the required dependencies:
pip install -r requirements.txt

3. Set up environment variables:
Create a file named .env in the root directory and add your Groq API key:
GROQ_API_KEY="your_groq_api_key_here"

4. Run the development server:
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

Access the API documentation at http://127.0.0.1:8000/docs.