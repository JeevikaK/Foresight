from utils.llava_utils import *
from utils.whisper_utils import *
from utils.detectron_utils import *
from utils.llms.gemini_utils import *
from utils.coreChat import Chat
from PIL import Image
from io import BytesIO
import tempfile
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
import cv2
import numpy as np
from fastapi.responses import FileResponse
from pathlib import Path

llavaModel = None
whisperModel = None
detectronModel = None
geminiModel = None
chat = None

@asynccontextmanager
async def ModelLifespan(app: FastAPI):
    global llavaModel, whisperModel, detectronModel, chat, geminiModel
    print("Loading Models...zz")
    llavaModel = LLavaChat(load_in_4bit=True,
                    bnb_4bit_compute_dtype=torch.float16,
                    bnb_4bit_use_double_quant=True,
                    bnb_4bit_quant_type='nf4',
                    device_map = 'auto',)
    print("ShareGPTV4 Loaded..")
    detectronModel = Detectron("COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml")
    print("Detectron Model Loaded")
    geminiModel = Gemini(model='gemini-pro')
    print("Gemini Loaded")
    chat = Chat(geminiModel=geminiModel,
            llavaModel=llavaModel,
            detectronModel=detectronModel) 
    yield

    llavaModel = None
    whisperModel = None
    detectronModel = None
    geminiModel = None
    chat = None


async def begin_conversation(prompt, image):
    content = await image.read()
    image = Image.open(BytesIO(content)).convert('RGB')
    chat.prepareMetadata(image)
    response, segmented_image = chat.start_chat(prompt)
    segmented_image = cv2.cvtColor(np.array(segmented_image), cv2.COLOR_RGB2BGR)
    segmented_image = cv2.rotate(segmented_image, cv2.ROTATE_90_CLOCKWISE)
    temp_file_path = "./static/segemented_image.jpg"
    cv2.imwrite(temp_file_path, segmented_image)
    return {
        "prompt": prompt,
        "response" : response,
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