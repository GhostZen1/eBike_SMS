import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/auth/controller/login_controller.dart';
import 'package:ebikesms/modules/auth/screen/signup/matric_number_screen.dart';
import 'package:ebikesms/modules/auth/screen/forgetpassword/screen/forgetpassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false; // To toggle password visibility
  final bool _rememberMe = false; // To toggle "Remember Me" radio button

  void _handleLogin() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and password are required')),
      );
    } else {
      LoginController().loginValidation(context, username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: ColorConstant.hintBlue, // Light blue background
      body: Column(
        children: [
          // Header section with wave and icon
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
          const SizedBox(height: 50),

          // Login text fields and buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Welcome back!",
                    style: TextStyle(
                      fontSize: 30,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                // Username TextField
                Center(
                  child: SizedBox(
                    width: 350.0,
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors
                            .white, // White background for the text field
                        labelText: 'Matric Number',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: Color(
                                  0xFF003366), // Change to your desired color
                              width: 2.0,
                            )),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                // Password TextField with Show/Hide functionality
                Center(
                  child: SizedBox(
                    width: 350.0, // Set the width of the container
                    child: TextField(
                      obscureText: !_passwordVisible,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors
                            .white, // White background for the text field
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: Color(0xFF003366), // Blue border color
                            width: 2.0,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                // Login Button
                Center(
                  child: SizedBox(
                    width: 350.0,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgetPasswordScreen()),
                          );
                      // Add your desired action here, like navigating to another screen
                      print("Forgot Password tapped!");
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          // Sign Up Link
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MatricPasswordScreen()),
                    );
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                        color: Colors.blue, fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
