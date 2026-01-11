
import base64
import firebase_admin
from firebase_admin import credentials, db
from flask import Flask
from flask_socketio import SocketIO, emit, join_room

# --- FIREBASE SETUP ---
# Download your firebase-adminsdk.json from Firebase Console > Project Settings > Service Accounts
cred = credentials.Certificate("firebase-adminsdk.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://astra-farm-robot-default-rtdb.asia-southeast1.firebasedatabase.app'
})

# --- FLASK & SOCKET.IO SETUP ---
app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*", max_http_buffer_size=10000000) # 10MB buffer for video

# In-memory store for connected devices
devices = {}

@socketio.on('connect')
def handle_connect():
    print("Client connected")

@socketio.on('disconnect')
def handle_disconnect():
    print("Client disconnected")

# --- 1. DEVICE HANDSHAKE ---
@socketio.on('join_device')
def on_join(data):
    """
    Data format: {'id': 'robot_1', 'type': 'app' | 'robot' | 'cam'}
    """
    device_id = data.get('id')
    device_type = data.get('type')
    sid = request.sid
    
    join_room(device_id) # All devices for 'robot_1' join the same room
    print(f"Device joined: ID={device_id}, Type={device_type}")

# --- 2. COMMAND RELAY (App -> ESP32) ---
@socketio.on('app_command')
def on_command(data):
    """
    Data format: {'id': 'robot_1', 'command': 'FORWARD'}
    """
    robot_id = data.get('id')
    command = data.get('command')
    print(f"Command received for {robot_id}: {command}")
    
    # Forward command to the ESP32 (which is in the same room)
    # The ESP32 should listen for 'robot_execute_command'
    emit('robot_execute_command', command, to=robot_id)

# --- 3. VIDEO RELAY (ESP32-CAM -> App) ---
@socketio.on('cam_stream_frame')
def on_video_frame(data):
    """
    Receives binary JPEG data from ESP32-CAM and forwards it to the App.
    """
    robot_id = data.get('id')
    frame_data = data.get('image') # Binary or Base64
    
    # Forward to the App listening on 'app_video_update'
    emit('app_video_update', frame_data, to=robot_id)

# --- 4. SENSOR DATA (ESP32 -> Firebase) ---
@socketio.on('update_sensors')
def on_sensor_update(data):
    """
    ESP32 sends sensor data here. We update Firebase.
    """
    robot_id = data.get('id', 'robot_1')
    
    # Example Data: {'moisture': 65, 'lat': 30.7, 'lon': 76.8}
    
    # Update Soil Health
    if 'moisture' in data:
        ref = db.reference(f'robot/soil-health')
        ref.update({
            'moisture': data['moisture'] / 100.0, # Convert 65 to 0.65
            'ph': data.get('ph', 7.0)
        })
        
    # Update Location
    if 'lat' in data and 'lon' in data:
        ref = db.reference(f'robot/location')
        ref.update({
            'latitude': data['lat'],
            'longitude': data['lon']
        })

    print("Firebase Updated with Sensor Data")

if __name__ == '__main__':
    # Listen on all interfaces (0.0.0.0) so ESP32/App can connect via IP
    socketio.run(app, host='0.0.0.0', port=5000)