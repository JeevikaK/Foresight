import torch
import os, json, cv2, random
import detectron2
import numpy as np
import os, json, cv2, random
from detectron2 import model_zoo
from detectron2.engine import DefaultPredictor
from detectron2.config import get_cfg
from detectron2.utils.visualizer import Visualizer, ColorMode
from detectron2.utils.colormap import colormap
from detectron2.data import MetadataCatalog, DatasetCatalog


class Detectron:
    def __init__(self, checkpoint_file):
        self.cfg = get_cfg()
        self.merge_from_file(model_zoo.get_config_file(checkpoint_file))
        self.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.5 
        self.MODEL.WEIGHTS = model_zoo.get_checkpoint_url(checkpoint_file)
        self.predictor = DefaultPredictor(self.cfg)
        self.initialise()

    def initialise(self):
        self.cache = {}
        self.metadata_detectron = []
        self.prediction_data = []

    def make_prediction(self, image):
        self.image = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
        outputs = self.predictor(self.image)
        predictions = outputs["instances"].to("cpu")
        prediction_data = []

        for i in range(len(predictions)):
            class_id = predictions.pred_classes[i].item()

            prediction_dict = {
                "class_id": class_id,
                "class_name": MetadataCatalog.get(self.cfg.DATASETS.TRAIN[0]).thing_classes[predictions.pred_classes[i]],
                "color": MetadataCatalog.get(self.cfg.DATASETS.TRAIN[0]).thing_colors[class_id][::-1],
                "scores": predictions.scores[i].item()
            }
            prediction_data.append(prediction_dict)
        self.prediction_data = prediction_data
    
    def create_metadata(self, image):
        self.make_prediction(image=image)
        pos = 0
        for object in self.prediction_data:
            if object.get('class_name') not in self.cache:
                object_data = {}
                object_data['object_name'] = object.get('class_name')
                object_data['count'] = 1
                object_data['color'] = object.get('color')
                self.metadata_detectron.append(object_data)
                self.cache[object.get('class_name')] = pos
                pos+=1
            else:
                i = self.cache[object.get('class_name')]
                metadata = self.metadata_detectron[i]
                metadata['count'] = metadata.get('count') + 1
        return self.metadata_detectron