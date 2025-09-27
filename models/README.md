
---

# Download pre-trained models

### 🛠️ Hugging Face to **ONNX** Converter 

**`models/models_to_onnx.py`**

This is a unified Python script to convert Hugging Face models into the **ONNX** format for optimized inference.

The script handles two main use cases:

1. **Feature extraction models** (e.g., `sentence-transformers`).
2. **Token classification models** (e.g., Named Entity Recognition - NER).

It automatically downloads the model and organizes the exported files in a structured subdirectory.

### Requirements

Before running the script, make sure you have the following Python packages installed:

```bash
pip install torch transformers onnx onnxruntime optimum
```

### 🔧 How to Use

| Argument          | Description                                           |
| ----------------- | ----------------------------------------------------- |
| `-m` / `--model`  | Hugging Face model name (e.g., `dslim/bert-base-NER`) |
| `-o` / `--output` | Output folder name                                    |
| `--mode`          | `feature` or `token` (default: `token`)               |
| `--base_dir`      | Base save directory (default: `./models`)             |


### Examples

```bash
python models/model_to_onnx.py -m="dbmdz/bert-large-cased-finetuned-conll03-english" -o="bert-large-cased-finetuned-conll03-english"
```

```bash
python models/model_to_onnx.py -m="sentence-transformers/all-MiniLM-L6-v2" -o="sentence-transformers/all-MiniLM-L6-v2"
```

### Output

```
./models/
  ├── model_to_onnx.py 
  ├── sentence-transformers/all-MiniLM-L6-v2/ 
  │    ├── model.onnx (via optimum)
  │    └── tokenizer/ 
  └── dslim/bert-base-NER/  
       ├── model.onnx  
       ├── label_map.json  
       └── tokenizer/ 
```

---
