import 'dart:convert';
import 'package:ebikesms/ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReportController {
  static String _apiUrl = '${ApiBase.baseUrl}/user_report.php';

  Future<int> sendReport(
    BuildContext context,
    String reportType,
    String reportDetail,
  ) async {
    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    try {
      // Retrieve user ID from secure storage
      String? userId = await _secureStorage.read(key: 'userId');

      if (userId == null) {
        // User ID not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User ID not found. Please log in again.')),
        );
        return 0; // Indicate failure
      }

      // Prepare request payload
      Map<String, String> requestPayload = {
        'user_id': userId,
        'report_type': reportType,
        'report_detail': reportDetail,
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode != 200) {
        print('Non-200 status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP error: ${response.statusCode}')),
        );
        return 0;
      }

      // Handle response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Success response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!')),
          );

          // Return success
          return 1;
        } else {
          // Failure from API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseData['message'] ?? 'Failed to submit report.')),
          );
          return 0;
        }
      } else {
        // HTTP error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Server error. Please try again later.')),
        );
        return 0;
      }
    } catch (e) {
      // Exception handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      return 0;
    }
  }
}
