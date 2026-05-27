import tensorflow as tf
import numpy as np

class RandomShadowLayer(tf.keras.layers.Layer):
    """Custom Keras Layer that applies random shadow overlays to simulate field conditions."""
    def __init__(self, shadow_intensity_range=(0.4, 0.7), **kwargs):
        super(RandomShadowLayer, self).__init__(**kwargs)
        self.min_intensity, self.max_intensity = shadow_intensity_range

    def call(self, inputs, training=None):
        if not training:
            return inputs
        
        # Apply shadow batch-wise or element-wise
        return tf.map_fn(self._apply_single_shadow, inputs)

    def _apply_single_shadow(self, image):
        # Coordinates for shadow polygon (we define a triangle across random edges)
        h, w, c = image.shape
        x1 = tf.random.uniform([], 0, w, dtype=tf.int32)
        y1 = tf.random.uniform([], 0, h, dtype=tf.int32)
        x2 = tf.random.uniform([], 0, w, dtype=tf.int32)
        y2 = tf.random.uniform([], 0, h, dtype=tf.int32)

        # Generate coordinate grid
        x_indices = tf.range(w)
        y_indices = tf.range(h)
        X, Y = tf.meshgrid(x_indices, y_indices)

        # Draw a line splitting the image for shadow region
        # Line formula: (y - y1) * (x2 - x1) - (x - x1) * (y2 - y1)
        line_val = (Y - y1) * (x2 - x1) - (X - x1) * (y2 - y1)
        shadow_mask = tf.cast(line_val > 0, tf.float32)
        shadow_mask = tf.expand_dims(shadow_mask, axis=-1)

        # Calculate random shadow intensity
        intensity = tf.random.uniform([], self.min_intensity, self.max_intensity)
        
        # Apply shadow overlay (darkening mask region)
        shadowed_image = image * (1.0 - shadow_mask * intensity)
        return tf.clip_by_value(shadowed_image, 0.0, 255.0)

def get_augmentation_pipeline(img_size=224):
    """
    Returns a TF Sequential model applying crop-field realistic data augmentations.
    Optimized for training MobileNetV3 classifiers.
    """
    pipeline = tf.keras.Sequential([
        # Spatial Augmentations
        tf.keras.layers.RandomFlip("horizontal_and_vertical"),
        tf.keras.layers.RandomRotation(factor=0.15, fill_mode="reflect"),
        tf.keras.layers.RandomZoom(height_factor=0.2, width_factor=0.2, fill_mode="reflect"),
        tf.keras.layers.RandomTranslation(height_factor=0.1, width_factor=0.1, fill_mode="reflect"),

        # Visual Augmentations
        tf.keras.layers.RandomBrightness(factor=0.2),
        tf.keras.layers.RandomContrast(factor=0.2),

        # Custom Field Shadow Simulations
        RandomShadowLayer(shadow_intensity_range=(0.3, 0.65))
    ])
    return pipeline

def apply_gaussian_blur(image, kernel_size=5, sigma=1.0):
    """Helper to apply blur (optional post-processing tf operation)."""
    # Create Gaussian Kernel
    x = np.arange(-kernel_size // 2 + 1.0, kernel_size // 2 + 1.0)
    xx, yy = np.meshgrid(x, x)
    kernel = np.exp(-(xx**2 + yy**2) / (2.0 * sigma**2))
    kernel = kernel / np.sum(kernel)
    kernel = np.expand_dims(kernel, axis=-1)
    kernel = np.repeat(kernel, 3, axis=-1) # Repeat for RGB
    kernel = np.expand_dims(kernel, axis=-1) # Shape: [size, size, 3, 1]
    
    # TensorFlow Depthwise Conv2D
    blur_kernel = tf.constant(kernel, dtype=tf.float32)
    expanded = tf.expand_dims(image, axis=0) # Batch dim
    blurred = tf.nn.depthwise_conv2d(
        expanded, blur_kernel, strides=[1, 1, 1, 1], padding='SAME'
    )
    return tf.squeeze(blurred, axis=0)
