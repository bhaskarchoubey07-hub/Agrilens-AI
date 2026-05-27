import tensorflow as tf
import numpy as np

class TFLiteModelConverter:
    def __init__(self, keras_model_path="best_crop_model.h5"):
        self.keras_model_path = keras_model_path

    def convert_to_float16(self, output_path="agri_model_float16.tflite"):
        """Converts Keras model to TFLite format with Float16 quantization (runs fast on mobile GPU)."""
        print(f"Loading Keras model from: {self.keras_model_path}")
        model = tf.keras.models.load_model(self.keras_model_path)
        
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        
        print("Converting to Float16 TFLite model...")
        tflite_model = converter.convert()
        
        with open(output_path, "wb") as f:
            f.write(tflite_model)
        print(f"Float16 TFLite model successfully exported to: {output_path}")
        return output_path

    def convert_to_int8(self, representative_data_gen, output_path="agri_model.tflite"):
        """
        Converts Keras model to TFLite with Full Integer (Int8) Quantization.
        This optimizes latency for execution on mobile CPU and shrinks the model size to ~1/4th.
        """
        print(f"Loading Keras model from: {self.keras_model_path}")
        model = tf.keras.models.load_model(self.keras_model_path)
        
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.representative_dataset = representative_data_gen
        
        # Enforce full integer quantization for inputs and outputs
        converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
        converter.inference_input_type = tf.uint8 # Or tf.int8
        converter.inference_output_type = tf.uint8
        
        print("Converting to full Int8 quantized TFLite model...")
        tflite_model = converter.convert()
        
        with open(output_path, "wb") as f:
            f.write(tflite_model)
        print(f"Int8 Quantized TFLite model successfully exported to: {output_path}")
        return output_path

# Helper generator function for Int8 Quantization representative dataset
def representative_data_generator():
    # Yields simulated image tensors representing the typical inputs
    # In production, yield ~100-200 actual images from the validation dataset folder
    for _ in range(100):
        # Generate dummy input images matching model shape (1, 224, 224, 3)
        data = np.random.rand(1, 224, 224, 3).astype(np.float32)
        yield [data]

if __name__ == "__main__":
    import sys
    converter = TFLiteModelConverter()
    
    # Run Float16 conversion by default
    try:
        converter.convert_to_float16()
    except Exception as e:
        print(f"Failed to convert (Make sure 'best_crop_model.h5' exists): {e}")
