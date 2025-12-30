# Camera.py
import cv2

class Camera:
    def __init__(self, camera_id=0, width=640, height=480):
        self.cap = cv2.VideoCapture(camera_id)
        self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
        self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)

        if not self.cap.isOpened():
            raise RuntimeError("❌ Camera could not be opened")

    def capture_image(self):
        ret, frame = self.cap.read()
        if not ret:
            raise RuntimeError("❌ Failed to capture image")
        return frame

    def release(self):
        self.cap.release()
