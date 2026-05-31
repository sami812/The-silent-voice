import json
import os
import logging
from groq import Groq

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

def translate_signs_agent(words: list, location: str = None) -> dict:
    """
    Takes disconnected words and an optional location, forms a natural sentence, 
    generates 4 replies, and detects emergency contexts.
    """
    logger.info(f"Received words: {words} | Location: {location}")
    
    loc_context = f"The user is currently at: {location}." if location else ""
    
    prompt = f"""
    The following list contains disconnected words captured from a deaf person using sign language: {words}.
    {loc_context}
    
    Your tasks:
    1. Translate these words into a single, natural English sentence.
    2. Generate exactly 4 short English replies for the hearing person.
    3. Identify the 'context_type' using a single English word (e.g., Emergency, Medical, Casual).
    4. Set 'is_emergency' to true if the words indicate danger, severe pain, or a need for urgent help.
    5. If 'is_emergency' is true, write a brief Arabic distress message in 'whatsapp_msg' summarizing the situation and mentioning the location. If false, leave it empty.
    
    Return the result ONLY as a valid JSON object matching this exact structure:
    {{
        "translated_text": "Natural English sentence",
        "suggested_replies": ["Reply 1", "Reply 2", "Reply 3", "Reply 4"],
        "context_type": "Context word",
        "is_emergency": false,
        "whatsapp_msg": ""
    }}
    """
    
    try:
        response = client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama3-70b-8192", 
            temperature=0.3,
            response_format={"type": "json_object"} 
        )
        
        return json.loads(response.choices[0].message.content)
        
    except Exception as e:
        logger.error(f"Error in translate_signs_agent: {str(e)}")
        raise e

def suggest_replies_for_deaf_agent(text: str, location: str = None) -> dict:
    """
    Generates 4 suggested replies for the deaf person based on the hearing person's text.
    """
    logger.info(f"Generating replies for text: {text} | Location: {location}")
    
    loc_context = f"Context: They are currently at {location}." if location else ""
    
    prompt = f"""
    A hearing person has spoken the following English sentence to a deaf person: "{text}"
    {loc_context}
    
    Your task:
    Generate exactly 4 short, natural English replies that the deaf person can select to respond. 
    Use the location context to make the replies more accurate if provided.
    
    Return the result ONLY as a valid JSON object matching this exact structure:
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
        
        return json.loads(response.choices[0].message.content)
        
    except Exception as e:
        logger.error(f"Error in suggest_replies_for_deaf_agent: {str(e)}")
        raise e