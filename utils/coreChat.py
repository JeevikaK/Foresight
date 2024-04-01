from utils.llms.gemini_utils import Gemini
from utils.llava_utils import LLavaChat
from utils.detectron_utils import Detectron
import string
import copy

class Chat:
    def __init__(self, geminiModel: Gemini, llavaModel: LLavaChat, detectronModel: Detectron):
        self.llm = geminiModel
        self.lmm = llavaModel
        self.detectron = detectronModel
        self.metadata_detectron = []
        self.metadata_lmm = ''
        self.translator = str.maketrans('', '', string.punctuation)
        self.history = []
        self.segmented_image = None

    def prepareMetadata(self, img):
        self.detectron.initialise()
        self.metadata_detectron = self.detectron.create_metadata(img)
        self.segmented_image = self.detectron.segment_image()
        print(self.metadata_detectron)
        self.metadata_lmm = self.lmm.LMM_preprocessing(img_path=img, metadata_detectron=self.metadata_detectron)
        print(self.metadata_lmm)
        cache = self.detectron.cache
        self.detailed_items = {}
        for item, pos in cache.items():
            for split in item.split():
                self.detailed_items[split] = pos

    def colorize(self, text):
        word = text.translate(self.translator).lower()
        for item in self.detailed_items:
            if item in word:
                index = self.detailed_items[item]
                color = self.metadata_detectron[index]['color']
                html_color = "#{:02x}{:02x}{:02x}".format(color[0], color[1], color[2])
                return f'<font color={html_color}>{text}</font>'
        return text
    
    def format_response(self, response, query):
        formatted_response = map(lambda word: self.colorize(word), response.split())
        formatted_response = " ".join(formatted_response)
        # formatted_response = "<p>" + formatted_response + "</p>"
        snippet = {
            'you' : query,
            'AI': formatted_response
        }
        self.history.append(snippet)
        return formatted_response
    
    def get_history(self):
        return self.history

    def start_chat(self, query):
        self.llm.init_chat()
        return self.continue_chat(query), self.segmented_image
    
    def continue_chat(self, query):
        premodel_context = self.lmm.process_query(query, self.metadata_detectron)
        print(premodel_context)
        print()
        response = self.llm.continue_chat(self.metadata_lmm, self.metadata_detectron, query, premodel_context)
        print(response)
        print()
        return self.format_response(response, query)