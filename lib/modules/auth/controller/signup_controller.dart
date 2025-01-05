import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ebikesms/modules/auth/screen/login.dart';
import 'package:ebikesms/modules/auth/screen/signup/authentication.dart'; // Import biometric screen
import 'package:ebikesms/ip.dart';

class SignupController extends ChangeNotifier {
  Future<int> registerUser(
    BuildContext context,
    String userEmail,
    String matricNumber,
    String password,
    String fullname,
    String username,
  ) async {
    

    // // Navigate to BiometricAuthScreen and await its result
    // int? authResult = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const BiometricAuthScreen()),
    // );

    // Proceed based on biometric authentication result
    // if (authResult == 1) {
      // Biometric authentication successful, proceed with API call
      final url = Uri.parse("${ApiBase.baseUrl}/signup.php");
      
      try {
        // Make a POST request with JSON body
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "user_email": userEmail,
            "matric_number": matricNumber,
            "password": password,
            "user_name": username,
            "full_name": fullname,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);

          if (responseBody['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful')),
            );

            // Navigate to login screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
            return 1; // Indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseBody['message'] ?? 'Registration failed')),
            );
            return 0; // Indicate failure
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server error. Please try again later.')),
          );
          return 0; // Indicate failure
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        return 0; // Indicate failure
      }
    // } else {
    //   // Biometric authentication failed
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Biometric authentication failed')),
    //   );
    //   return 0; // Indicate failure
    // }
  }
}
