import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ebikesms/ip.dart';
import 'package:http/http.dart' as http;

class UserController extends ChangeNotifier {
  static Future<Map<String, dynamic>> updateUserRideTime(
      int userId,
      int deductedRideTime,
      ) async {
    // Define the API URL
    final url = Uri.parse("${ApiBase.baseUrl}/update_user_ride_time.php"); // TODO: Ensure host is running
    debugPrint("Starting HTTP POST request to URL: $url");

    try {
      // Perform the HTTP POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
          "available_ride_time": deductedRideTime,
        }),
      );

      debugPrint("Response status code: ${response.statusCode}");

      // Check if the HTTP response indicates failure
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {
          'status': 0,
          'message': "HTTP response indicates failure: ${response.statusCode}",
        };
      }

      // Decode the response body as JSON
      final responseBody = json.decode(response.body);
      debugPrint("Decoded response body: $responseBody");

      // Handle the response status
      if (responseBody['status'] == 'success') {
        return {
          'status': 1,
          'message': responseBody['message'],
        };
      } else if (responseBody['status'] == 'error') {
        return {
          'status': 0,
          'message': responseBody['message'],
        };
      }

      // Handle unexpected statuses
      return {
        'status': 0,
        'message': responseBody['message'] ?? "Unexpected response format",
      };

    } on FormatException catch (e) {
      debugPrint("Error decoding response body: $e");
      return {
        'status': 0,
        'message': "Failed to decode response: $e",
      };

    } catch (e) {
      debugPrint("Unexpected error occurred: $e\nStack trace: ${StackTrace.current}");
      return {
        'status': 0,
        'message': "An unexpected error occurred: $e",
      };
    }
  }
}
