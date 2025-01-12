#include <WiFi.h>
#include <TinyGPSPlus.h>
#include <HardwareSerial.h>

// WiFi credentials
const char* ssid = "WIFI SSID";
const char* password = "WIFI Password";

// Define RX2 and TX2 pins
#define RX2_PIN 16  // GPIO16 is RX2
#define TX2_PIN 17  // GPIO17 is TX2

// Create a TinyGPS++ object
TinyGPSPlus gps;

// Create a hardware serial object for UART2
HardwareSerial gpsSerial(2);

// Create a WiFi server
WiFiServer server(80);

// Global variables to store GPS data
String latitude = "N/A";
String longitude = "N/A";

void setup() {
    // Initialize serial communication for debugging
    Serial.begin(115200);
    Serial.println("Initializing GPS module...");

    // Initialize UART2 for GPS communication
    gpsSerial.begin(9600, SERIAL_8N1, RX2_PIN, TX2_PIN);

    // Connect to WiFi
    Serial.print("Connecting to WiFi...");
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.print(".");
    }
    Serial.println("\nConnected!");
    Serial.println("IP Address: " + WiFi.localIP().toString());

    // Start the server
    server.begin();
}

void loop() {
    // Process GPS data
    while (gpsSerial.available() > 0) {
        char c = gpsSerial.read();
        if (gps.encode(c)) {  // Feed the GPS data to TinyGPS++
            if (gps.location.isValid()) {
                latitude = String(gps.location.lat(), 6);
                longitude = String(gps.location.lng(), 6);

                // Display the location in the Serial Monitor
                Serial.print("Latitude: ");
                Serial.print(latitude);
                Serial.print(" Longitude: ");  
                Serial.println(longitude);
            } else {
                latitude = "N/A";
                longitude = "N/A";
                Serial.println("Waiting for GPS signal...");
            }
        }
    }

    // Handle HTTP requests
    WiFiClient client = server.available();
    if (client) {
        Serial.println("New client connected.");
        String request = client.readStringUntil('\r');
        Serial.println(request);
        client.flush();

        // Send the GPS data as JSON response
        String response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n";
        response += "{";
        response += "\"latitude\": \"" + latitude + "\",";
        response += "\"longitude\": \"" + longitude + "\"";
        response += "}";
        client.print(response);
        client.stop();
        Serial.println("Client disconnected.");
    }
}