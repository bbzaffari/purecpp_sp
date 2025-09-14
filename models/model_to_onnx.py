import argparse
import os
import json
from pathlib import Path


BASE_DIR = os.path.join(os.path.dirname(__file__), "models")  # Base directory


def convert_feature_extraction_model(model_name):
    print(f"\nConverting feature extraction model: {model_name}")
    from optimum.onnxruntime import ORTModelForFeatureExtraction
    from transformers import AutoTokenizer

    dir_path = os.path.join(BASE_DIR, model_name)
    os.makedirs(dir_path, exist_ok=True)
    print(f"Directory created for the model: {dir_path}")

    model = ORTModelForFeatureExtraction.from_pretrained(model_name, export=True)
    tokenizer = AutoTokenizer.from_pretrained(model_name)

    model.save_pretrained(dir_path)
    tokenizer.save_pretrained(dir_path)
    print(f"Feature extraction model saved to: {dir_path}")

def convert_token_classification_model(model_name, output_name):
    print(f"\nConverting token classification model: {model_name}")
    from transformers import AutoModelForTokenClassification, AutoTokenizer, AutoConfig
    from transformers.onnx import export, FeaturesManager

    config = AutoConfig.from_pretrained(model_name)
    label_map = config.id2label
    dir_path = os.path.join(BASE_DIR, output_name)
    os.makedirs(dir_path, exist_ok=True)
    print(f"Directory created for the model: {dir_path}")

    with open(os.path.join(dir_path, "label_map.json"), "w") as f:
        json.dump(label_map, f)
    print(f"Label map saved to: {os.path.join(dir_path, 'label_map.json')}")

    model = AutoModelForTokenClassification.from_pretrained(model_name)
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    tokenizer.save_pretrained(os.path.join(dir_path, "tokenizer"))
    print(f"Tokenizer saved to: {os.path.join(dir_path, 'tokenizer')}")

    model_type = model.config.model_type
    feature = "token-classification"
    outpath = Path(os.path.join(dir_path, "model.onnx"))

    onnx_config = FeaturesManager.get_config(model_type=model_type, feature=feature)
    onnx_config = onnx_config(model.config)

    export(model=model, output=outpath, opset=14, preprocessor=tokenizer, config=onnx_config)
    print(f"Token classification model exported to: {outpath}")


# Main with argparse
def main():
    global BASE_DIR

    parser = argparse.ArgumentParser(description="Hugging Face to ONNX model converter")
    parser.add_argument("-m", "--model", required=True, help="Hugging Face model name (e.g., dslim/bert-base-NER)")
    parser.add_argument("-o", "--output", required=True, help="Output name for the exported folder")
    parser.add_argument("--mode", choices=["feature", "token"], default="token", help="Conversion mode: feature or token")
    parser.add_argument("--base_dir", default=BASE_DIR, help="Base directory to save the models")

    args = parser.parse_args()

    BASE_DIR = args.base_dir

    if args.mode == "feature":
        convert_feature_extraction_model(args.model)
    else:
        convert_token_classification_model(args.model, args.output)

if __name__ == "__main__":
    main()
