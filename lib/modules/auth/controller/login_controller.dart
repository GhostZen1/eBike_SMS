import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/widget/bottom_nav_bar.dart';
import 'user_storage_service.dart'; // Adjust the path as needed
import 'package:ebikesms/ip.dart';

class LoginController extends ChangeNotifier {
   final UserStorageService _userStorageService = UserStorageService();
   
  Future<void> loginValidation(
      BuildContext context, String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password are required')),
      );
      return; // Stop execution if validation fails
    }

    final url = Uri.parse("${ApiBase.baseUrl}/login.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"matric_number": username, "password": password}),
      );
      print("Response body: ${response.body}"); // Log the raw response

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          // Store the user_id locally or pass it to the next screen
          int userId = responseBody['user_id']; // Now this will work since user_id is part of the response
          String userType = responseBody['user_type'];

          await _userStorageService.saveUserId(userId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavBar(
                userId: userId,
                userType: userType,
              )
            ), // Pass userId to the next screen
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Login failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Server error.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      
    }
  }
}
