from dotenv import load_dotenv
import os
from utils.llms.base_llm import LLM
import google.generativeai as genai
load_dotenv()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

class Gemini(LLM):
    def __init__(self, model = 'gemini-pro', history = []) -> None:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        self.model = genai.GenerativeModel(model)
        self.chat = None
        super().__init__(self.model, history)

    def create_prompt(self, metadata_lmm, metadata_detectron, query, premodel_context):
        if self.history == []:
            prompt = f'''
                You are a helpful AI assistant who takes input from the user which is the query. You answer the query with the help of the following additional information -
                1. an PRE_MODEL_CONTEXT which is the output of the image to text model
                2. METADATA_DETECTRON which lists all the objects present in the scene along with the number of objects in a json format which is to be referred to as the ground truth
                3. METADATA_LMM which describes the image completely and gives additional context to what is in the image (this is again output of the image to text model)
                if the user is asking for information about a specific object, verify if it is in METADATA_DETECTRON first (Synonyms of the object names are allowed), if not ignore the premodel_result tell the object is absent in the image and you need further information.
                The correctness of the premodel_context depends on if the objects stated to be present in the image in the premodel_context are actually present in the METADATA_DETECTRON (or its Synonyms) if not premodel_context is wrong and you can tell you cannot answer the question since the context is absent.
                Example: the words People and person are Synonyms so its allowed to use them interchangeably
                PRE_MODEL_CONTEXT: "{premodel_context}"

                METADATA_DETECTRON:  {metadata_detectron}

                METADATA_LMM: "{metadata_lmm}"

                {query} based on the above information of METADATAS and PRE_MODEL_CONTEXT, keep the information of METADATAS and PRE_MODEL_CONTEXT internal to you,
                do not let the user know that youre making prediction by looking at the results of two different models.
                It should be as if youre prediction is solely from a single model.
                Do not answer more than what is asked. Do not make your own assumptions.
                Now give an answer to the user and imagine youre directly looking at the image and talk to the user as if youre having a friendly conversation with them.
                '''

        else:
            prompt = f'''
            PRE_MODEL_CONTEXT: "{premodel_context}"

            METADATA_DETECTRON:  {metadata_detectron}

            METADATA_LMM: "{metadata_lmm}"
            '''
        return prompt
    
    def init_chat(self):
        self.history = []
        self.chat = self.model.start_chat(history = self.history)

    def continue_chat(self, metadata_lmm, metadata_detectron, query, premodel_context):
        prompt = self.create_prompt(metadata_lmm, metadata_detectron, query, premodel_context)
        response = self.chat.send_message(prompt)
        return response.text
        