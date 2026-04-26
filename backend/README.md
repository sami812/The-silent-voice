# The Silent Voice - Smart Chat Backend API

This backend service powers the "Smart Chat" interface for The Silent Voice application. Built with FastAPI and the Groq LLM (Llama3), it is designed to process disconnected words from a computer vision model, translate them into natural English sentences, and generate contextual smart replies for both Deaf and Hearing users.

## Features
- **Context-Aware Translation:** Converts raw sign language keywords into grammatically correct English sentences.
- **Smart Replies Engine:** Generates 4 contextual response suggestions for both parties.
- **Sentiment/Context Analysis:** Identifies the context of the message (e.g., Emergency, Medical, Casual) to help the frontend adjust UI elements dynamically.

---

<<<<<<< HEAD
##  Deployment & Setup Instructions
=======
## API Documentation


###  Live Environment (Online)
* **API Base URL:** `link.onrender.com`
* **Live Swagger Docs:** `link.onrender.com/docs`

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
>>>>>>> 78ef5d7d4fd8617ccf656b9a752cef737f4a50a0

### Option 1: Running Locally (For Testing)
1. Open your terminal in the `backend` folder.
2. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Set your Groq API key as an environment variable. Create a file named `.env` in the backend folder and add:
   ```env
   GROQ_API_KEY=your_api_key_here
   ```
4. Run the FastAPI server:
   ```bash
   uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
   ```
5. The API documentation will be available at: `http://localhost:8000/docs`

### Option 2: Deploying to Render (Production)
Since this repository might be private, the owner of the repo should follow these steps to deploy the backend:
1. Go to [Render Dashboard](https://dashboard.render.com/) and click **New +** -> **Web Service**.
2. Connect this GitHub repository.
3. Configure the service with the following settings:
   - **Root Directory:** `backend`
   - **Runtime:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn api.main:app --host 0.0.0.0 --port $PORT`
4. Expand **Environment Variables** and add your API Key:
   - **Key:** `GROQ_API_KEY`
   - **Value:** `(Insert the Groq API Key here)`
5. Click **Create Web Service**. Once deployed, copy the provided `onrender.com` URL to use in the Flutter app.

---

<<<<<<< HEAD
## API Endpoints

### 1. Process Signs (Deaf -> Hearing)
Translates disconnected words captured from sign language into a full sentence and provides 4 suggested replies for the hearing person.

* **URL:** `/api/process-signs`
* **Method:** `POST`
* **Request Body:**
  ```json
  {
      "words": ["pain", "stomach", "hospital"]
  }
  ```
* **Response:**
  ```json
  {
      "translated_text": "I feel a severe pain in my stomach and I need to go to the hospital.",
      "suggested_replies": [
          "Are you okay? Do you need an ambulance?",
          "I will take you to the hospital right now.",
          "When did the pain start?",
          "Have you taken any medication?"
      ],
      "context_type": "Emergency"
  }
  ```

### 2. Suggest Replies (Hearing -> Deaf)
Takes the text spoken/written by the hearing person and generates 4 smart replies for the deaf person to choose from.

* **URL:** `/api/suggest-replies`
* **Method:** `POST`
* **Request Body:**
  ```json
  {
      "text": "Your total bill is 150 dollars, sir."
  }
  ```
* **Response:**
  ```json
  {
      "suggested_replies": [
          "Here you go.",
          "Can I pay with a credit card?",
          "That is quite expensive.",
          "Thank you for your help."
      ]
  }
  ```
=======
Access the API documentation at http://127.0.0.1:8000/docs.
>>>>>>> 78ef5d7d4fd8617ccf656b9a752cef737f4a50a0
