import whisper

class Whisper:
    def __init__(self, model_name):
        self.model = whisper.load_model(model_name)

    def transcribe(self, audio):
        result = self.model.transcribe(audio)
        return result.get("text")
