#include <WiFi.h>
#include "ThingSpeak.h" // Include the ThingSpeak library

// Wi-Fi credentials
const char* ssid = "Thamilezai";         // Replace with your Wi-Fi SSID
const char* password = "thamil123ez"; // Replace with your Wi-Fi password

// ThingSpeak credentials
unsigned long channelID = 2778481;      // Your ThingSpeak channel ID
const char* writeAPIKey = "1TFTBXI21ER3LUPY"; // Your Write API Key

// Signal pin
const int signalPin = A0; // Analog pin connected to the signal source

WiFiClient client; // Wi-Fi client for ThingSpeak communication

void setup() {
  // Initialize serial communication
  Serial.begin(9600);

  // Connect to Wi-Fi
  connectToWiFi();

  // Initialize ThingSpeak
  ThingSpeak.begin(client);
}

void loop() {
  // Read signal value (e.g., from an EMG or ECG sensor)
  int signalValue = analogRead(signalPin);
  Serial.println("Signal Value: " + String(signalValue));

  // Send data to ThingSpeak
  if (WiFi.status() == WL_CONNECTED) {
    ThingSpeak.setField(1, signalValue); // Assign signalValue to field 1
    int writeResult = ThingSpeak.writeFields(channelID, writeAPIKey);
    if (writeResult == 200) {
      Serial.println("Data sent successfully to ThingSpeak!");
    } else {
      Serial.println("Failed to send data to ThingSpeak. Code: " + String(writeResult));
    }
  } else {
    Serial.println("Wi-Fi disconnected. Reconnecting...");
    connectToWiFi();
  }

  delay(2000); // ThingSpeak allows updates every 15 seconds
}

// Function to connect to Wi-Fi
void connectToWiFi() {
  Serial.print("Connecting to Wi-Fi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to Wi-Fi!");
}