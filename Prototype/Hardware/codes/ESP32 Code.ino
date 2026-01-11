
#include <WiFi.h>
#include <SocketIoClient.h>
#include <ArduinoJson.h>

// --- WIFI CONFIG ---
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

// --- PI SERVER CONFIG ---
char host[] = "192.168.0.149"; // IP of your Raspberry Pi
int port = 5000;

SocketIoClient socket;
String robotId = "robot_1";

// --- PIN DEFINITIONS (L298N) ---
#define IN1 18
#define IN2 19
#define IN3 22
#define IN4 23
// Optional: Enable pins for PWM speed control
#define ENA 32 
#define ENB 33

// --- SETUP ---
void setup() {
    Serial.begin(115200);
    
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
    pinMode(IN3, OUTPUT);
    pinMode(IN4, OUTPUT);
    pinMode(ENA, OUTPUT);
    pinMode(ENB, OUTPUT);
    
    // Set max speed
    digitalWrite(ENA, HIGH); 
    digitalWrite(ENB, HIGH);

    stopMotors();

    // Connect WiFi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nWiFi Connected");

    // Setup Socket.IO
    socket.on("connect", onConnect);
    socket.on("robot_execute_command", onCommand);
    
    socket.begin(host, port);
}

// --- MAIN LOOP ---
unsigned long lastSensorUpdate = 0;

void loop() {
    socket.loop();

    // Send Sensor Data every 5 seconds
    if (millis() - lastSensorUpdate > 5000) {
        sendSensorData();
        lastSensorUpdate = millis();
    }
}

// --- SOCKET EVENTS ---
void onConnect(const char * payload, size_t length) {
    Serial.println("Connected to Server!");
    // Identify as robot
    String json = "{\"id\":\"" + robotId + "\", \"type\":\"robot\"}";
    socket.emit("join_device", json.c_str());
}

void onCommand(const char * payload, size_t length) {
    String command = String(payload);
    Serial.print("Command received: ");
    Serial.println(command);

    if (command == "\"FORWARD\"") moveForward();
    else if (command == "\"BACKWARD\"") moveBackward();
    else if (command == "\"LEFT\"") turnLeft();
    else if (command == "\"RIGHT\"") turnRight();
    else if (command == "\"STOP\"") stopMotors();
}

// --- MOTOR FUNCTIONS ---
void moveForward() {
    digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);
    digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);
}
void moveBackward() {
    digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);
    digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);
}
void turnLeft() {
    digitalWrite(IN1, LOW); digitalWrite(IN2, HIGH);
    digitalWrite(IN3, HIGH); digitalWrite(IN4, LOW);
}
void turnRight() {
    digitalWrite(IN1, HIGH); digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW); digitalWrite(IN4, HIGH);
}
void stopMotors() {
    digitalWrite(IN1, LOW); digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW); digitalWrite(IN4, LOW);
}

// --- SENSOR DATA ---
void sendSensorData() {
    // Reading dummy data (Replace with analogRead(SOIL_PIN))
    int moisture = 78; 
    float lat = 30.7333;
    float lon = 76.7794;
    
    // Create JSON
    DynamicJsonDocument doc(1024);
    doc["id"] = robotId;
    doc["moisture"] = moisture;
    doc["lat"] = lat;
    doc["lon"] = lon;
    
    String output;
    serializeJson(doc, output);
    
    socket.emit("update_sensors", output.c_str());
}