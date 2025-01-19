import 'dart:convert';
import 'package:ebikesms/ip.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For API calls
import 'dart:math';

class EmailVerification {

bool CheckPattern(String email) {
  final basicPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; 
  final utemPattern =
      r'^[BDM]\d{9}@student\.utem\.edu\.my$'; // New pattern for UTEM emails
  
  // Check both patterns
  return RegExp(basicPattern).hasMatch(email) && RegExp(utemPattern).hasMatch(email);
}

// Sends the verification email
Future<int> checkEmailPattern(String email, BuildContext context) async {
  if (!CheckPattern(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid email format!'),
      ),
    );
    return 0; // Invalid email format
  } else {
    return 1;
  }
}


   String generateOtp() {
    final random = Random();
    final otp = List.generate(6, (index) => random.nextInt(10)).join();
    return otp;
  }

 Future<int> sendOtpToBackend(String email, String OTP) async {
  final response = await http.post(
    Uri.parse('${ApiBase.baseUrl}/sent_otp.php'),
    body: {
      'email': email,
      'otp': OTP,
    },
  );

  if (response.statusCode == 200) {
    // Handle success
    print("OTP sent successfully.");
    return 1;
  } else {
    // Handle error
    print("Failed to send OTP.");
    return 0;
  }
}


Future<int> checkEmailExistence(String email) async {
  final url = Uri.parse('${ApiBase.baseUrl}/check_email.php');  // Replace with your actual API URL

  // Prepare the data to be sent in the request body
  final Map<String, dynamic> data = {'user_email': email};

  // Send the POST request to the PHP API
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // If the API returns a success status code (200)
      final responseData = json.decode(response.body);

      if (responseData['status'] == 'error') {
        print('Email already exists: ${responseData['message']}');
        return 1;
      } else {
        print('Email does not exist: ${responseData['message']}');
        return 0;
      }
    } else {
      print('Failed to check email. Status code: ${response.statusCode}');
      return 0;
    }
  } catch (error) {
    print('Error occurred: $error');
    return 0;
  }
}


}
