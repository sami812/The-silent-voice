from groq import Groq
from core.config import settings

class InterpreterAgent:
    def __init__(self):
        # Initialize the Groq client using the API key from the core settings
        self.client = Groq(api_key=settings.GROQ_API_KEY)
        
        # The System Prompt defines the AI's personality and rules
        self.system_prompt = (
            "You are a professional Sign Language Interpreter. "
            "Convert the provided list of isolated words into a natural, grammatically correct sentence. "
            "Use the context (location/movement) to make the sentence accurate. "
            "Output ONLY the final sentence. No explanations."
        )

    def translate(self, words: list[str], context: dict = None) -> str:
        # Handle cases where no signs were detected
        if not words:
            return "No signs detected."

        # Set default context if none is provided by the mobile app
        if context is None:
            context = {"location": "unknown", "is_moving": False}

        # Format the raw input and extract context details
        raw_input = ", ".join(words)
        location = context.get("location", "unknown")
        movement = "moving" if context.get("is_moving") else "stationary"
        
        # Build the final prompt for the AI model
        user_content = f"Words: [{raw_input}]. Context: User is at {location} and is {movement}."

        try:
            print("[Agent: Interpreter] Sending data to Groq API...")
            
            # Call the Groq API with the specified model from settings
            chat_completion = self.client.chat.completions.create(
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": user_content}
                ],
                model=settings.MODEL_NAME,
                temperature=0.5,
            )
            
            print("[Agent: Interpreter] AI Response received successfully.")
            
            # Return the cleaned text response
            return chat_completion.choices[0].message.content.strip()

        except Exception as e:
            # Error handling in case the API call fails
            print(f"[Agent: Interpreter] Error: {e}")
            return "System Error: Translation failed."

# Quick standalone test to verify the architecture
if __name__ == "__main__":
    agent = InterpreterAgent()
    print("\n--- Testing Clean Architecture System ---")
    result = agent.translate(["hospital", "where", "now"], {"location": "street", "is_moving": True})
    print(f"Result: {result}\n")