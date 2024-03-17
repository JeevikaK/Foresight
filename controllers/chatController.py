from main import chatModel, whisperModel
from PIL import Image
from io import BytesIO
import tempfile
import os

async def begin_conversation(prompt, image):
    content = await image.read()
    image = Image.open(BytesIO(content)).convert('RGB')
    response = chatModel.start_new_chat(image, prompt)
    return {
        "prompt": prompt,
        "response" : response
    }

async def continue_chat(prompt):
    response = chatModel.continue_chat(prompt)
    return {
        "prompt": prompt,
        "response": response
    }

async def get_history():
    history = chatModel.conversation_history()
    return {
        "history": history,
    }

async def transcribe(file):
    temp_file = tempfile.NamedTemporaryFile(delete=False)
    temp_file.write(file.file.read())
    trasncription = whisperModel.transcribe(temp_file.name)
    temp_file.close()
    os.unlink(temp_file.name)
    return{
        "transcription": trasncription
    }