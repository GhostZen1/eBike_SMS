import 'package:ebikesms/modules/global_import.dart';
import 'package:flutter/material.dart';
import 'package:ebikesms/shared/utils/custom_icon.dart'; // Import CustomIcon
import 'package:ebikesms/modules/auth/screen/forgetpassword/screen/set_new_password.dart';


class EmailExistScreen extends StatefulWidget {
  final String otpSent;
  final String email;
  const EmailExistScreen({super.key, required this.email , required this.otpSent});

  @override
  _EmailExistScreenState createState() => _EmailExistScreenState();
}

class _EmailExistScreenState extends State<EmailExistScreen> {
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();
  final TextEditingController _otpController5 = TextEditingController();
  final TextEditingController _otpController6 = TextEditingController();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _focusNode5.dispose();
    _focusNode6.dispose();
    super.dispose();
  }

  String getOtpInput() {
  return _otpController1.text +
      _otpController2.text +
      _otpController3.text +
      _otpController4.text +
      _otpController5.text +
      _otpController6.text;
}


    bool varifyOTP(String _otpSent, String _otpInput) {
    if (_otpSent == _otpInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Correct.')),
      );
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong OTP.')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String email = widget.email;
    String otpsent = widget.otpSent;
    // Get screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorConstant.hintBlue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstant.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.04),
                CustomIcon.email(screenWidth * 0.3),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Check your email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: ColorConstant.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Enter the code from the email we sent to\n$email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontFamily: 'Poppins',
                    color: ColorConstant.grey,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // OTP Input Fields (6 TextFields for OTP)
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOtpTextField(_otpController1, _focusNode1, _focusNode2),
                        _buildOtpTextField(_otpController2, _focusNode2, _focusNode3),
                        _buildOtpTextField(_otpController3, _focusNode3, _focusNode4),
                        _buildOtpTextField(_otpController4, _focusNode4, _focusNode5),
                        _buildOtpTextField(_otpController5, _focusNode5, _focusNode6),
                        _buildOtpTextField(_otpController6, _focusNode6, null),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.08),
                // Resend OTP Button
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't receive the email?",
                        style: TextStyle(fontSize: screenWidth * 0.04),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle resend action
                        },
                        child: Text(
                          "RESEND NEW CODE",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                // Submit Button
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: () {
                         String userInput = getOtpInput();
                         bool result = varifyOTP(otpsent, userInput);

                          if (result == true){                            
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SetNewPasswordScreen(email: email),
                                ),
                              );
                          }
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.15),
                // Note Text at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Text(
                      "Note: if you can't see the email on the inbox,\nplease check it in trash/spam",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: ColorConstant.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpTextField(TextEditingController controller, FocusNode currentFocus, FocusNode? nextFocus) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorConstant.hintBlue,
          width: 2.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // Move to next text field when a digit is entered
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          } else {
            // Move to previous text field if the user deletes the digit
            if (currentFocus != null) {
              FocusScope.of(context).previousFocus();
            }
          }
        },
      ),
    );
  }
}
