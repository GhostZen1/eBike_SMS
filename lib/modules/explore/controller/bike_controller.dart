import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ebikesms/ip.dart';
import 'package:http/http.dart' as http;

class BikeController extends ChangeNotifier {
  // Method to fetch all bike data
  static Future<Map<String, dynamic>> getAllBikeData() async {
    return await _makePostRequest("get_all_bike.php");
  }

  // Method to fetch single bike data by bikeId
  static Future<Map<String, dynamic>> getSingleBikeData(String bikeId) async {
    return await _makePostRequest(
      "get_single_bike.php",
      body: {"bike_id": bikeId},
    );
  }

  // Generalized private method for making HTTP POST requests
  static Future<Map<String, dynamic>> _makePostRequest(String endpoint,
      {Map<String, dynamic>? body}) async {
    final url = Uri.parse("${ApiBase.baseUrl}/$endpoint");
    debugPrint("Starting HTTP POST request to URL: $url");

    try {
      debugPrint("Response status code: $body");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: (body == null) ? null : json.encode(body),
      );

      debugPrint("Response status code: ${response.statusCode}");

      if (response.statusCode != 200) {
        return _handleError("HTTP response indicates failure");
      }

      final responseBody = json.decode(response.body);
      debugPrint("Decoded response body: $responseBody");

      // Handle response based on status
      if (responseBody['status'] == 'error') {
        debugPrint(
            "Request failed. Response status: ${responseBody['status']}");
        return _handleError(responseBody['message']);
      }

      if (responseBody['status'] == 'success') {
        debugPrint(
            "Request successful. Response status: ${responseBody['status']}");
        return {
          'status': 1, // Indicate success
          'message': responseBody['message'],
          'data': responseBody['data'],
        };
      }

      return _handleError("Unexpected status in response body");
    } on FormatException catch (e) {
      debugPrint("Error decoding response body: $e");
      return _handleError(e.toString());
    } catch (e) {
      debugPrint("Unexpected error occurred during HTTP POST request: $e");
      return _handleError(e.toString());
    }
  }

  // Helper method for error handling
  static Map<String, dynamic> _handleError(String message) {
    return {
      'status': 0, // Indicate failure
      'message': message,
    };
  }
}
