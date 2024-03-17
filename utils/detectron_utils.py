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


def Load_detectron_weights(checkpoint_file):
    cfg = get_cfg()
    cfg.merge_from_file(model_zoo.get_config_file(checkpoint_file))
    cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.5 
    cfg.MODEL.WEIGHTS = model_zoo.get_checkpoint_url(checkpoint_file)
    return DefaultPredictor(cfg)