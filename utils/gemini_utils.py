from dotenv import load_dotenv
import os
import google.generativeai as genai
load_dotenv()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

class GeminiChat:
    def __init__(self, model = 'gemini-pro', history = []):
        self.model = genai.GenerativeModel(model)
        self.history = history