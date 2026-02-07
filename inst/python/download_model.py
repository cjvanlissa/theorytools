# download_model.py
from transformers import AutoTokenizer, AutoModel
import os

def download_model(model, path):
  os.makedirs(path, exist_ok=True)
  tokenizer = AutoTokenizer.from_pretrained(model)
  model = AutoModel.from_pretrained(model)
  model.save_pretrained(path)
  tokenizer.save_pretrained(path)
  return path
