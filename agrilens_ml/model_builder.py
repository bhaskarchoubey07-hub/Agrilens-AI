import tensorflow as tf

class ModelBuilder:
    @staticmethod
    def build_mobilenet_v3(num_classes, img_shape=(224, 224, 3), fine_tune_layers=0):
        """
        Builds a classifier using MobileNetV3Large backbone.
        Pre-trained weights from ImageNet are loaded, and custom dense layers are appended.
        """
        # Primary Backbone: optimized for latency and CPU execution on mobile devices
        base_model = tf.keras.applications.MobileNetV3Large(
            input_shape=img_shape,
            include_top=False,
            weights="imagenet",
            pooling="avg" # Global Average Pooling
        )

        # Freeze the base model by default
        base_model.trainable = True
        
        # Freezing layers if we do transfer learning
        if fine_tune_layers > 0:
            # Freeze all layers except the last N
            for layer in base_model.layers[:-fine_tune_layers]:
                layer.trainable = False
        else:
            # Freeze entire backbone
            base_model.trainable = False

        # Build Sequential Model
        model = tf.keras.Sequential([
            base_model,
            tf.keras.layers.Dense(256, activation="relu"),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dropout(0.4),
            tf.keras.layers.Dense(num_classes, activation="softmax")
        ])

        return model, base_model

    @staticmethod
    def build_efficientnet_v2(num_classes, img_shape=(224, 224, 3)):
        """
        Builds a classifier using EfficientNetV2B0 backbone.
        """
        base_model = tf.keras.applications.EfficientNetV2B0(
            input_shape=img_shape,
            include_top=False,
            weights="imagenet",
            pooling="avg"
        )
        
        base_model.trainable = False # Frozen backbone for transfer learning

        model = tf.keras.Sequential([
            base_model,
            tf.keras.layers.Dense(256, activation="relu"),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dropout(0.35),
            tf.keras.layers.Dense(num_classes, activation="softmax")
        ])

        return model, base_model

    @staticmethod
    def get_yolo_placeholder_pipeline():
        """
        Documentation/Helper outlining future YOLO object detection configuration.
        """
        return {
            "model_architecture": "YOLOv8-Nano (Detection Task)",
            "output_format": "Bounding Box Coordinates [x_min, y_min, x_max, y_max, class_id, confidence]",
            "integration_status": "Planned expansion. Requires boundary box label formats (e.g. YOLO/COCO JSON format)."
        }

if __name__ == "__main__":
    # Test compilation
    model, base = ModelBuilder.build_mobilenet_v3(num_classes=8)
    model.summary()
