import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ebikesms/modules/global_import.dart'; // Ensure this import is correct for your project

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false; // Track authentication status

  Future<void> _authenticate() async {
    // Prevent re-authentication if already authenticating
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true; // Start loading
    });

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;

      if (canCheckBiometrics) {
        List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();

        bool authenticated = false;

        // Only attempt to authenticate with the first available biometric type
        if (availableBiometrics.contains(BiometricType.face)) {
          authenticated = await auth.authenticate(
            localizedReason: 'Authenticate using your face',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          authenticated = await auth.authenticate(
            localizedReason: 'Authenticate using your fingerprint',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );
        } else {
          authenticated = await auth.authenticate(
            localizedReason: 'Enter your PIN to proceed',
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
            ),
          );
        }

        if (authenticated) {
          Navigator.pop(context, 1); // Successful authentication
        } else {
          Navigator.pop(context, 0); // Authentication failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication failed, please try again')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No biometrics available. Use PIN instead.')),
        );
        await _usePinAuthentication(); // Fallback to PIN
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      Navigator.pop(context, 0); // Error during authentication
    } finally {
      setState(() {
        _isAuthenticating = false; // Stop loading
      });
    }
  }

  Future<void> _usePinAuthentication() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Enter your PIN to proceed',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        Navigator.pop(context, 1); // Successful authentication
      } else {
        Navigator.pop(context, 0); // Authentication failed
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error using PIN: $e')),
      );
      Navigator.pop(context, 0); // Error during PIN authentication
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ColorConstant.hintBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with Wave Design and Back Button
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
                      icon: const Icon(Icons.arrow_back, color: ColorConstant.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),

              // Main content section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Verify that it's you",
                      style: TextStyle(
                        fontSize: 30,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Just one more step",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.08),

                    // Authentication icon
                    const Icon(
                      Icons.fingerprint,
                      size: 100,
                      color: Color(0xFF003366),
                    ),
                    SizedBox(height: screenHeight * 0.1),

                    // Get Started Button
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.07,
                        child: ElevatedButton(
                          onPressed: _isAuthenticating ? null : () async {
                            await _authenticate(); // Call authentication
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isAuthenticating
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Get Started",
                                  style: TextStyle(
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
