#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

// WiFi Credentials
const char* ssid = " ";
const char* password = " ";

// Web server on port 80
ESP8266WebServer server(80);

// GPIO pin connected to the buzzer's I/O pin
const int buzzerPin = D5;

void setup() {
  // Set the buzzer pin as OUTPUT
  pinMode(buzzerPin, OUTPUT);
  digitalWrite(buzzerPin, LOW); // Ensure the buzzer starts off

  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting...");
  }
  Serial.println("Connected!");

  // Print the IP address of the ESP8266
  Serial.println("ESP8266 IP Address: ");
  Serial.println(WiFi.localIP());

  // Define a route to trigger the buzzer
  server.on("/ring", []() {
    digitalWrite(buzzerPin, HIGH); // Turn the buzzer on
    delay(1000);                   // Keep it on for 1 second
    digitalWrite(buzzerPin, LOW);  // Turn the buzzer off
    server.send(200, "text/plain", "Buzzer activated");
  });

  // Start the web server
  server.begin();
  Serial.println("Server started");
}

void loop() {
  // Handle incoming client requests
  server.handleClient();
}
