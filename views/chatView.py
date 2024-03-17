from main import app, chatModel
from typing import Union, Annotated
from fastapi import File, Form, UploadFile
from controllers import chatController

@app.get("/")
def read_root():
    return {"Hello": "World", 'test': str(chatModel)}


@app.post("/begin_conversation")
async def begin_conversation(prompt: Annotated[str, Form()], 
                        image: Annotated[UploadFile, File()],
                        ):
    return chatController.begin_conversation(prompt, image)
    


@app.post("/converse")
async def converse(prompt: Annotated[str, Form()],):
    return chatController.continue_chat



@app.get("/get_convo_history")
async def history():
    return chatController.get_history()



@app.post("/transcribe")
async def transcribe(file: Annotated[UploadFile, File()]):
    return chatController.transcribe()
