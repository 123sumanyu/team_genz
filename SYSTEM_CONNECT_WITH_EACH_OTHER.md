# ASTRA-Farm-Robot – System Connection Overview

This document explains how all parts of the system are connected and how data flows between the mobile app and the robot.

---

## Main Components

- Mobile App (ASTRA App)
- Firebase (cloud backend)
- ESP32 Dev Board
- Raspberry Pi 4
- ESP32-CAM modules
- Motor drivers (L293D)
- DC gear motors
- 12V LiPo battery with 5V buck converter

---

## Power Distribution

- A 12V LiPo battery is the main power source.
- A 5V buck converter steps down 12V to 5V.
- 5V output powers:
  - Raspberry Pi
  - ESP32 Dev Board
  - ESP32-CAM modules
- Motors receive power through motor drivers.
- All grounds are connected together.

---

## App to Robot Communication

1. User opens the ASTRA mobile app.
2. User logs in using Firebase Authentication.
3. App sends commands to Firebase.
4. Commands are stored in the robot’s data section.
5. ESP32 reads commands from Firebase using WiFi.

The app never connects directly to the robot hardware.

---

## Firebase Role

Firebase acts as the middle layer.

- Stores user data
- Stores robot commands
- Stores robot status
- Controls access permissions

This allows many users to use the app without affecting the robot.

---

## ESP32 Dev Board Role

- Connects to WiFi
- Reads commands from Firebase
- Sends motor control signals to L293D motor drivers
- Controls direction and speed of motors
- Sends robot status back to Firebase

ESP32 handles real-time control.

---

## Motor Control

- L293D motor drivers are used to protect the controller.
- Each motor driver controls two DC gear motors.
- ESP32 sends digital signals to motor drivers.
- Motors move based on received commands.

Motors never connect directly to Firebase or the app.

---

## Raspberry Pi Role

- Acts as the main processing unit
- Receives video data from ESP32-CAM modules
- Handles higher-level logic and coordination
- Can communicate with ESP32 when needed
- Sends processed data to Firebase

---

## ESP32-CAM Role

- Captures live images or video
- Sends camera data wirelessly to Raspberry Pi
- Used for monitoring and future vision features

ESP32-CAM does not control motors.

---

## Data Flow Summary
