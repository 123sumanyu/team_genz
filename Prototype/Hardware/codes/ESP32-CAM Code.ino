#include "esp_camera.h"
#include <WiFi.h>
#include <SocketIoClient.h>

// --- CAMERA PIN MAP (AI-Thinker) ---
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27
#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

char host[] = "192.168.0.149";
int port = 5000;

SocketIoClient socket;
String robotId = "robot_1";

void setup() {
  Serial.begin(115200);

  // 1. Config Camera
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  
  // Lower quality for faster streaming over Socket.IO
  config.frame_size = FRAMESIZE_QVGA; // 320x240
  config.jpeg_quality = 12; // 0-63, lower is better quality but higher size
  config.fb_count = 2;

  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println("Camera init failed");
    return;
  }

  // 2. Connect WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  // 3. Connect Socket
  socket.on("connect", onConnect);
  socket.begin(host, port);
}

void onConnect(const char * payload, size_t length) {
  Serial.println("CAM Connected");
  String json = "{\"id\":\"" + robotId + "\", \"type\":\"cam\"}";
  socket.emit("join_device", json.c_str());
}

// Buffer for JSON payload (Image data + ID)
// Increase size if images are large
char payloadBuffer[15000]; 

void loop() {
  socket.loop();

  // Capture and Send Frame
  camera_fb_t * fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
    return;
  }

  // NOTE: Sending binary over basic Socket.IO client in Arduino can be tricky.
  // We send it as a raw byte array if the library supports it, or use a custom event.
  // Using the 'socket.emit' with binary pointer:
  
  // Construct a small header or just send raw binary and let server handle 'robotId' via socket session.
  // But for simplicity with this library, we might need to rely on the server knowing who we are (via sid).
  
  // Actually, standard practice for Arduino SocketIO text-only libraries is Base64.
  // But if using a Binary-capable library:
  socket.emit("cam_stream_frame", fb->buf, fb->len);

  esp_camera_fb_return(fb);
  
  // Limit FPS
  delay(100); 
}8
