from contextlib import asynccontextmanager
from utils.llava_utils import *
from utils.whisper_utils import *
from utils.detectron_utils import *
from utils.gemini_utils import *
from fastapi import FastAPI


chatModel = None
whisperModel = None
detectronModel = None

@asynccontextmanager
async def ModelLifespan(app: FastAPI):
    global chatModel, whisperModel
    print("Loading Models...")
    chatModel = LLavaChat(load_in_4bit=True,
                    bnb_4bit_compute_dtype=torch.float16,
                    bnb_4bit_use_double_quant=True,
                    bnb_4bit_quant_type='nf4',
                    device_map = 'auto',)
    print("ShareGPTV4 Loaded..")
    whisperModel = Whisper("base")
    print("Whisper Loaded...")
    detectronModel = Load_detectron_weights("COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml")
    print("Detectron Model Loaded")
    geminiModel = LLM()
    print("Gemini Loaded")
    yield
    chatModel = None
    whisperModel = None
    detectronModel = None
    geminiModel = None
    
    

app = FastAPI(lifespan=ModelLifespan)


