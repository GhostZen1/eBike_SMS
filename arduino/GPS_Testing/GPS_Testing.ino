#include <WiFi.h>
#include <HTTPClient.h>
#include <TinyGPSPlus.h>
#include <HardwareSerial.h>

// WiFi credentials
const char* ssid = "WIFI SSID";
const char* password = "WIFI PASSWORD";

// Define RX2 and TX2 pins for GPS
#define RX2_PIN 16  // GPIO16 is RX2
#define TX2_PIN 17  // GPIO17 is TX2

// Create a TinyGPS++ object
TinyGPSPlus gps;

// Create a hardware serial object for UART2
HardwareSerial gpsSerial(2);

// API endpoint (replace with your local server's IP address)
const char* serverURL = "http://192.168.0.243/save_location.php"; // Replace x.x with your local IP
const char* serverURLGPS = "http://192.168.0.243/esp_hosting.php"; // Replace x.x with your local IP

//const char* serverURL = "https://etourmersing.com/Ebike_API/save_location.php"; // Replace x.x with your local IP
//const char* serverURLGPS = "https://etourmersing.com/Ebike_API/esp_hosting.php";

// Global variables to store GPS data
String latitude = "N/A";
String longitude = "N/A";
int count = 0;

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
}

void loop() {

    testArduinoConnection();
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

                // Send data to server
                sendToServer(latitude, longitude);
            } else {
                Serial.println("Waiting for GPS signal...");
            }
        }

        count = count + 1;

        if(count>2000){
          count = 0;
        }
    }

    //delay(10000); // Send data every 10 seconds (adjust as needed)
}

void sendToServer(String lat, String lng) {
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;

        // Specify the URL
        http.begin(serverURL);

        // Specify the POST request headers and payload
        http.addHeader("Content-Type", "application/x-www-form-urlencoded");
        String payload = "bike_id=B25001&latitude=" + lat + "&longitude=" + lng;

        // Send the POST request
        int httpResponseCode = http.POST(payload);

        // Check the HTTP response
        if (httpResponseCode > 0) {
            String response = http.getString();
            Serial.println("Server Response: " + response);
        } else {
            Serial.println("Error sending data: " + String(httpResponseCode));
        }

        http.end();
    } else {
        Serial.println("WiFi not connected!");
    }
}

void testArduinoConnection(){
  if (WiFi.status() == WL_CONNECTED){

    
    delay(5000);
    HTTPClient http1;

    http1.begin(serverURLGPS);

    http1.addHeader("Content-Type", "application/x-www-form-urlencoded");
    String payload = "landmark_id=L31&latitude=success "+ String(count);

    // Send the POST request
        int httpResponseCode1 = http1.POST(payload);

        // Check the HTTP response
        if (httpResponseCode1 > 0) {
            String response = http1.getString();
            Serial.println("Server Response: " + response);
            Serial.println("Sent");
        } else {
            Serial.println("Error sending data: " + String(httpResponseCode1));
        }

        http1.end();


    
  } else {
        Serial.println("WiFi not connected!");
    }
  

  
   
    
}