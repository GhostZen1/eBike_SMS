import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RingPage extends StatelessWidget {
  final String esp8266Ip;

  // Constructor to accept ESP8266 IP
  RingPage({required this.esp8266Ip});

  // Function to send a GET request to the ESP8266 to ring the bike
  Future<void> ringBike() async {
    final url = Uri.parse('http://192.168.0.51/ring'); // Use provided IP address
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Bike is ringing!");
        // Optionally show a success message
      } else {
        print("Failed to ring the bike.");
        // Optionally show an error message
      }
    } catch (e) {
      print("Error: $e");
      // Handle connection errors
    }
  }

  @override
  Widget build(BuildContext context) {
    // Automatically trigger the ringBike function when the page is loaded
    Future.delayed(Duration.zero, () {
      ringBike();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Ring Bike'),
      ),
      body: Center(
        child: Text(
          'Ringing the bike...',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
