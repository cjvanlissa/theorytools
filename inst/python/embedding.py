# embedding.py
from transformers import AutoTokenizer, AutoModel
import numpy as np
import torch
    
def get_embeddings(texts, model_path):
    """Generate SciBERT embeddings for a list of texts (returns numpy array)."""
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    model = AutoModel.from_pretrained(model_path)
    model.eval()

    embeddings = []
    for text in texts:
        # Ensure text is a str
        if text is None:
            text = ""
        inputs = tokenizer(
            text,
            return_tensors="pt",
            truncation=True,
            padding=True,
            max_length=512
        )
        with torch.no_grad():
            outputs = model(**inputs)
            # Use [CLS] token / first token embedding
            emb = outputs.last_hidden_state[:, 0, :].cpu().numpy()
            embeddings.append(emb.flatten())
    return np.array(embeddings)
