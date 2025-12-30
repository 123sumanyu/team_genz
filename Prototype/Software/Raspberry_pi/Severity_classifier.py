# Severity_classifier.py
class SeverityClassifier:
    def __init__(self, model_path=None):
        self.model = None
        self.model_path = model_path

        if model_path:
            self.load_model()

    def load_model(self):
        # Placeholder for severity model
        print("✅ Severity model loaded")

    def classify(self, disease_name, confidence):
        """
        Simple rule-based severity logic.
        Replace with ML model later.
        """
        if confidence >= 0.85:
            return "High"
        elif confidence >= 0.60:
            return "Medium"
        else:
            return "Low"
