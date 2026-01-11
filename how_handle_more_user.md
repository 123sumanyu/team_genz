# ASTRA-Farm-Robot

This project is a farm robot controlled using a mobile app.
Firebase is used as the backend between the app and the robot.

---

## How the System Works

The robot does not connect to users directly.

All communication goes through Firebase.

Users → App → Firebase → Robot  
Robot → Firebase → App → Users

---

## How It Handles More Users

Each user has a unique login ID.

Firebase stores user data separately, so users do not affect each other.

Example structure:

users/
  user_1  
  user_2  

robots/
  robot_1  
    command  
    status  

---

## Robot Control Logic

- The robot listens to only one command location in Firebase
- Only the latest command is executed
- Old commands are ignored
- The robot runs one command at a time

This prevents crashes even if many users use the app at once.

---

## User Access Control

- Only the assigned user can control a robot
- Other users can only view robot data
- Firebase rules control permissions
- The robot does not handle authentication

---

## Scaling

When users increase:
- Firebase handles more app connections
- App works normally
- Robot code stays the same

The robot always:
- Reads data at fixed intervals
- Executes one command at a time

---

## Key Point

Users scale in Firebase.  
Robots stay controlled and limited.

---

## Tech Used

- Flutter
- Firebase Authentication
- Firebase Firestore / Realtime Database
- Embedded controller for robot
