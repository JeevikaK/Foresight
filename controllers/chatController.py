from main import llavaModel, whisperModel, geminiModel, detectronModel
from utils.coreChat import Chat
from PIL import Image
from io import BytesIO
import tempfile
import os

chat = Chat(geminiModel=geminiModel,
            llavaModel=llavaModel,
            detectronModel=detectronModel) 

async def begin_conversation(prompt, image):
    content = await image.read()
    image = Image.open(BytesIO(content)).convert('RGB')
    chat.prepareMetadata(image)
    response = chat.start_chat(prompt)
    return {
        "prompt": prompt,
        "response" : response,
        # "image": image
    }

def continue_chat(prompt):
    response = chat.continue_chat(prompt)
    return {
        "prompt": prompt,
        "response": response
    }

def get_history():
    history = chat.get_history()
    return {
        "history": history,
    }

def transcribe(file):
    temp_file = tempfile.NamedTemporaryFile(delete=False)
    temp_file.write(file.file.read())
    trasncription = whisperModel.transcribe(temp_file.name)
    temp_file.close()
    os.unlink(temp_file.name)
    return{
        "transcription": trasncription
    }