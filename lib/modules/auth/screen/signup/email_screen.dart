import 'package:flutter/material.dart';
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/auth/controller/email_verification.dart';
import 'package:ebikesms/modules/auth/screen/signup/email_exist_otp.dart';

class EmailScreen extends StatefulWidget {
  final String matricnumber, password;

  const EmailScreen(
      {super.key, required this.matricnumber, required this.password});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _email = TextEditingController();
  String otp = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorConstant.hintBlue,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with Stack for Vector3 Image and Back Button
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Vector_3.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: ColorConstant.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Almost There!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.085,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.black,
                    ),
                  ),
                  Text(
                    "Enter your UTeM email address",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.normal,
                      color: ColorConstant.grey,
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: screenWidth * 0.85,
                    child: Column(
                      children: [
                        // Email TextField
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            labelText: "Student Email",
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: ColorConstant.grey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: ColorConstant.darkBlue,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Next Button
                  SizedBox(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_email.text.isNotEmpty) {
                          int result = await EmailVerification()
                              .checkEmailPattern(_email.text, context);

                          if (result == 1) {
                            try {
                              otp = EmailVerification().generateOtp();
                              result = await EmailVerification()
                                  .sendOtpToBackend(_email.text, otp);

                              if (result == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EmailExistScreen(
                                            email: _email.text,
                                            otpSent: otp,
                                            matricnumber: widget.matricnumber,
                                            password: widget.password,
                                          )),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter your email')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
