
from fastapi import FastAPI
from typing import Union, Annotated
from fastapi import File, Form, UploadFile
from controllers import chatController
from controllers.chatController import ModelLifespan


app = FastAPI(lifespan=ModelLifespan, debug=True)

# uvicorn main:app --reload --port 8000


@app.get("/")
async def read_root(): return {"Hello": "World",}

@app.post("/begin_conversation")
async def begin_conversation(prompt: Annotated[str, Form()], image: Annotated[UploadFile, File()],
                        ): return await chatController.begin_conversation(prompt, image)
    
@app.post("/converse")
async def converse(prompt: Annotated[str, Form()],): return chatController.continue_chat(prompt=prompt)

@app.get("/get_convo_history")
async def history(): return chatController.get_history()

@app.post("/transcribe")
async def transcribe(file: Annotated[UploadFile, File()]): return chatController.transcribe()
