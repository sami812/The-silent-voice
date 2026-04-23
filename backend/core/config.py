import os
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

class Settings:
    # Securely retrieve the Groq API Key
    GROQ_API_KEY: str = os.getenv("GROQ_API_KEY")
    
    # Define the default AI model to be used across the app
    MODEL_NAME: str = "llama-3.3-70b-versatile"

# Instantiate settings to be imported by other modules
settings = Settings()