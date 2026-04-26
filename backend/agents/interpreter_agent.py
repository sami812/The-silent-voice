import json
import os
import logging
from groq import Groq

# Set up logging to track requests and errors in the console
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize the Groq client
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

def translate_signs_agent(words: list) -> dict:
    """
    Takes a list of disconnected words, forms a natural English sentence,
    and generates 4 suggested replies for the hearing person.
    """
    logger.info(f"Received words for translation: {words}")
    
    prompt = f"""
    The following list contains disconnected words captured from a deaf person using sign language: {words}.
    
    Your tasks are as follows:
    1. Translate and formulate these disconnected words into a single, natural, and grammatically correct English sentence. Do not use robotic or AI-like phrasing. Make it sound like a real human talking.
    2. Generate exactly 4 short, practical English replies that a hearing person can use to respond to this statement in a chat interface.
    3. Identify the 'context_type' of the sentence using a single English word (e.g., Normal, Emergency, Question, Medical, Casual).
    
    You must return the result ONLY as a valid JSON object matching this exact structure:
    {{
        "translated_text": "Natural English sentence goes here",
        "suggested_replies": ["Reply 1", "Reply 2", "Reply 3", "Reply 4"],
        "context_type": "Context word here"
    }}
    """
    
    try:
        response = client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama3-70b-8192", 
            temperature=0.3, # Keeps the output stable and deterministic
            response_format={"type": "json_object"} 
        )
        
        raw_content = response.choices[0].message.content
        logger.info("Successfully generated translation and replies.")
        return json.loads(raw_content)
        
    except Exception as e:
        logger.error(f"Error in translate_signs_agent: {str(e)}")
        raise e

def suggest_replies_for_deaf_agent(text: str) -> dict:
    """
    Takes a sentence spoken by a hearing person and generates 
    4 suggested replies for the deaf person to choose from.
    """
    logger.info(f"Generating replies for text: {text}")
    
    prompt = f"""
    A hearing person has spoken the following English sentence to a deaf person: "{text}"
    
    Your task:
    Generate exactly 4 short, natural, and common English replies that the deaf person can select to respond quickly in a chat application.
    Avoid formal or robotic styles; make the replies feel like a natural, everyday conversation.
    
    You must return the result ONLY as a valid JSON object matching this exact structure:
    {{
        "suggested_replies": ["Reply 1", "Reply 2", "Reply 3", "Reply 4"]
    }}
    """
    
    try:
        response = client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama3-70b-8192",
            temperature=0.3,
            response_format={"type": "json_object"}
        )
        
        raw_content = response.choices[0].message.content
        logger.info("Successfully generated replies for deaf user.")
        return json.loads(raw_content)
        
    except Exception as e:
        logger.error(f"Error in suggest_replies_for_deaf_agent: {str(e)}")
        raise e