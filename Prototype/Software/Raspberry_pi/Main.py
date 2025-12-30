# Main.py
from Camera import Camera
from Disease_detection import DiseaseDetector
from Severity_classifier import SeverityClassifier
import cv2

def main():
    print("🚀 System Starting...")

    camera = Camera()
    detector = DiseaseDetector()
    severity_model = SeverityClassifier()

    try:
        image = camera.capture_image()
        print("📷 Image captured")

        disease, confidence = detector.predict(image)
        severity = severity_model.classify(disease, confidence)

        print("🦠 Disease Detected :", disease)
        print("📊 Confidence      :", confidence)
        print("⚠️ Severity Level  :", severity)

        # Optional display (remove if headless Pi)
        cv2.imshow("Captured Image", image)
        cv2.waitKey(3000)
        cv2.destroyAllWindows()

    except Exception as e:
        print("❌ Error:", e)

    finally:
        camera.release()
        print("✅ System Shutdown")

if __name__ == "__main__":
    main()
