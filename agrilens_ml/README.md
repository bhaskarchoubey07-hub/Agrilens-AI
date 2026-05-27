# AgriLens AI — ML Model Training Pipeline

This directory contains the source code for building, training, evaluating, and exporting the crop disease detection models for AgriLens AI.

---

## Directory Structure

```
agrilens_ml/
├── requirements.txt            # Training environment dependencies
├── dataset_processor.py        # Cleans duplicates (MD5) & structures Train/Val/Test
├── augmentations.py            # Augmentation pipeline (rotations, zooms, random shadows)
├── model_builder.py            # MobileNetV3Large & EfficientNetV2 architectures
├── train.py                    # Training loops, early stopping, performance plots
├── tflite_converter.py         # Post-Training Quantization (Float16/Int8) to TFLite
└── agrilens_pipeline.ipynb      # Complete Colab/Jupyter notebook runner
```

---

## Getting Started

### 1. Installation
Set up a python virtual environment and install the required machine learning packages:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Dataset Setup
Download the **PlantVillage Crop Disease** dataset from Kaggle or other repositories and extract it to a raw directory (e.g. `raw_dataset/`). The images should be grouped by subfolders named after the crop classes:
```
raw_dataset/
├── Wheat_Rust/
├── Tomato_Blight/
├── Potato_Early_Blight/
└── ...
```

### 3. Run Cleaning and Splitting
Run `dataset_processor.py` to filter corrupted files, remove duplicates via MD5 checks, and partition the data into 70% Train, 20% Val, 10% Test under the `data/` directory:
```bash
python dataset_processor.py raw_dataset/
```

### 4. Run Training
Train a MobileNetV3Large model with custom callbacks (Adam, Early stopping, Learning rate plateau scheduler):
```bash
python train.py
```
This script evaluates the test split, prints the classification metrics, and saves `best_crop_model.h5`, `training_performance_curves.png`, and `confusion_matrix.png`.

### 5. Convert to TFLite (Post-Training Quantization)
Convert the Keras model (`best_crop_model.h5`) to optimized `.tflite` binaries:
```bash
python tflite_converter.py
```
This outputs `agri_model.tflite` (full integer int8 quantized model, optimized for mobile CPUs) and `agri_model_float16.tflite` (optimized for GPU acceleration).

---

## Interactive Google Colab Runner
Double-click and open the [agrilens_pipeline.ipynb](file:///c:/Users/bhask/OneDrive/Documents/agritech/agrilens_ml/agrilens_pipeline.ipynb) notebook in Google Colab to run the entire pipeline with free cloud GPU accelerators.
