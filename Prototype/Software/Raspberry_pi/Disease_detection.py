# Disease_detection.py
import cv2
import numpy as np

class DiseaseDetector:
    def __init__(self, model_path=None):
        """
        model_path: path to trained ML model (optional for now)
        """
        self.model = None
        self.model_path = model_path

        if model_path:
            self.load_model()

    def load_model(self):
        # Placeholder for loading trained model
        # Example: keras.models.load_model(self.model_path)
        print("✅ Disease model loaded")

    def preprocess(self, image):
        image = cv2.resize(image, (224, 224))
        image = image / 255.0
        image = np.expand_dims(image, axis=0)
        return image

    def predict(self, image):
        """
        Returns:
            disease_name (str)
            confidence (float)
        """
        processed = self.preprocess(image)

        # 🔴 Replace with real model prediction
        disease_name = "Leaf Blight"
        confidence = 0.87

        return disease_name, confidence
