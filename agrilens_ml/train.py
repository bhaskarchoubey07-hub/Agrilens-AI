import os
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix
import pandas as pd

from model_builder import ModelBuilder
from augmentations import get_augmentation_pipeline

# Configure GPU growth to prevent memory locking
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print("GPU Memory Growth configured.")
    except RuntimeError as e:
        print(f"Error configuring GPU growth: {e}")

class CropDiseaseTrainer:
    def __init__(self, data_dir="data", img_size=224, batch_size=32, epochs=25):
        self.data_dir = data_dir
        self.img_size = img_size
        self.batch_size = batch_size
        self.epochs = epochs

    def load_datasets(self):
        """Loads train, validation, and test datasets from directory splits."""
        train_path = os.path.join(self.data_dir, "train")
        val_path = os.path.join(self.data_dir, "val")
        test_path = os.path.join(self.data_dir, "test")

        # Load datasets
        self.train_ds = tf.keras.utils.image_dataset_from_directory(
            train_path,
            image_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            label_mode="categorical"
        )
        self.class_names = self.train_ds.class_names
        self.num_classes = len(self.class_names)

        self.val_ds = tf.keras.utils.image_dataset_from_directory(
            val_path,
            image_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            label_mode="categorical"
        )

        self.test_ds = tf.keras.utils.image_dataset_from_directory(
            test_path,
            image_size=(self.img_size, self.img_size),
            batch_size=self.batch_size,
            label_mode="categorical",
            shuffle=False # Shuffle=False for confusion matrix parsing
        )

        # Autotune prefetches for performance
        AUTOTUNE = tf.data.AUTOTUNE
        
        # Apply Data Augmentation only to the training set
        augmentation_layer = get_augmentation_pipeline(self.img_size)
        self.train_ds = self.train_ds.map(
            lambda x, y: (augmentation_layer(x, training=True), y),
            num_parallel_calls=AUTOTUNE
        )

        # Rescale pixel values [0, 255] -> [0, 1] for all splits
        normalization_layer = tf.keras.layers.Rescaling(1./255)
        self.train_ds = self.train_ds.map(lambda x, y: (normalization_layer(x), y), num_parallel_calls=AUTOTUNE)
        self.val_ds = self.val_ds.map(lambda x, y: (normalization_layer(x), y), num_parallel_calls=AUTOTUNE)
        self.test_ds = self.test_ds.map(lambda x, y: (normalization_layer(x), y), num_parallel_calls=AUTOTUNE)

        self.train_ds = self.train_ds.prefetch(buffer_size=AUTOTUNE)
        self.val_ds = self.val_ds.prefetch(buffer_size=AUTOTUNE)
        self.test_ds = self.test_ds.prefetch(buffer_size=AUTOTUNE)

        print(f"Datasets loaded. Target classes count: {self.num_classes} ({self.class_names})")

    def run_training(self, model_type="mobilenet"):
        """Compiles and trains the selected model."""
        if model_type == "efficientnet":
            model, base_model = ModelBuilder.build_efficientnet_v2(self.num_classes)
        else:
            model, base_model = ModelBuilder.build_mobilenet_v3(self.num_classes)

        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
            loss="categorical_crossentropy",
            metrics=["accuracy", tf.keras.metrics.Precision(name="precision"), tf.keras.metrics.Recall(name="recall")]
        )

        # Callbacks
        checkpoint = tf.keras.callbacks.ModelCheckpoint(
            "best_crop_model.h5", 
            monitor="val_loss", 
            save_best_only=True, 
            verbose=1
        )
        early_stop = tf.keras.callbacks.EarlyStopping(
            monitor="val_loss", 
            patience=5, 
            restore_best_weights=True,
            verbose=1
        )
        lr_scheduler = tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.2,
            patience=3,
            min_lr=1e-6,
            verbose=1
        )

        print("Starting training run...")
        history = model.fit(
            self.train_ds,
            validation_data=self.val_ds,
            epochs=self.epochs,
            callbacks=[checkpoint, early_stop, lr_scheduler]
        )

        self.model = model
        self.history = history
        print("Training complete. Best model saved as 'best_crop_model.h5'")
        
        # Save historical plots
        self._plot_metrics()

    def evaluate_model(self):
        """Runs testing evaluations on test split and outputs comprehensive report."""
        print("Evaluating model against unseen test split...")
        results = self.model.evaluate(self.test_ds)
        print(f"Test Loss: {results[0]:.4f}")
        print(f"Test Accuracy: {results[1]:.4f}")
        print(f"Test Precision: {results[2]:.4f}")
        print(f"Test Recall: {results[3]:.4f}")

        # Classification predictions
        y_pred_probs = self.model.predict(self.test_ds)
        y_pred = np.argmax(y_pred_probs, axis=1)
        
        # Extract ground truths
        y_true = []
        for _, labels in self.test_ds:
            y_true.extend(np.argmax(labels.numpy(), axis=1))
        y_true = np.array(y_true)

        # Print detailed precision/recall/F1 stats
        print("\n=== CLASSIFICATION REPORT ===")
        print(classification_report(y_true, y_pred, target_names=self.class_names))

        # Confusion Matrix
        cm = confusion_matrix(y_true, y_pred)
        self._save_confusion_matrix(cm)

    def _plot_metrics(self):
        """Plots training accuracy & loss curves."""
        acc = self.history.history['accuracy']
        val_acc = self.history.history['val_accuracy']
        loss = self.history.history['loss']
        val_loss = self.history.history['val_loss']

        epochs_range = range(len(acc))

        plt.figure(figsize=(12, 5))
        plt.subplot(1, 2, 1)
        plt.plot(epochs_range, acc, label='Training Accuracy')
        plt.plot(epochs_range, val_acc, label='Validation Accuracy')
        plt.legend(loc='lower right')
        plt.title('Training and Validation Accuracy')

        plt.subplot(1, 2, 2)
        plt.plot(epochs_range, loss, label='Training Loss')
        plt.plot(epochs_range, val_loss, label='Validation Loss')
        plt.legend(loc='upper right')
        plt.title('Training and Validation Loss')
        
        plt.tight_layout()
        plt.savefig("training_performance_curves.png")
        print("Metrics plots saved to 'training_performance_curves.png'")

    def _save_confusion_matrix(self, cm):
        """Saves confusion matrix as a visual heatmap."""
        plt.figure(figsize=(10, 8))
        import seaborn as sns
        sns.heatmap(
            cm, 
            annot=True, 
            fmt='d', 
            cmap='Blues', 
            xticklabels=self.class_names, 
            yticklabels=self.class_names
        )
        plt.title('Confusion Matrix')
        plt.ylabel('Ground Truth')
        plt.xlabel('Prediction')
        plt.tight_layout()
        plt.savefig("confusion_matrix.png")
        print("Confusion Matrix plot saved to 'confusion_matrix.png'")

if __name__ == "__main__":
    trainer = CropDiseaseTrainer(epochs=2) # Default 2 epochs for sanity verification
    trainer.load_datasets()
    trainer.run_training(model_type="mobilenet")
    trainer.evaluate_model()
