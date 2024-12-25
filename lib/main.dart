<<<<<<< Updated upstream
=======
import 'package:ebikesms/modules/auth/screen/signup.dart';
import 'package:ebikesms/modules/explore/sub-screen/navigation/screen/nav_destination.dart';
>>>>>>> Stashed changes
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/menu/screen/menu.dart';
import 'package:ebikesms/modules/menu/sub-menu/ride_history/screen/ride_history.dart';
import 'package:ebikesms/modules/menu/sub-menu/settings/screen/settings.dart';
import 'package:ebikesms/modules/menu/sub-menu/time_top_up/screen/time_top_up.dart';
import 'package:ebikesms/modules/qr_scanner/screen/qr_scanner.dart';
import 'package:ebikesms/shared/widget/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'modules/auth/screen/login.dart'; // Adjust the path as needed
import 'modules/auth/controller/user_storage_service.dart'; // Adjust the path as needed
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add dependency in pubspec.yaml
<<<<<<< Updated upstream
import 'package:ebikesms/modules/auth/screen/forgetpassword/screen/email_exist_otp.dart';
import 'package:ebikesms/modules/auth/screen/signup/matric_number_screen.dart';
import 'package:ebikesms/modules/auth/screen/signup/username_screen.dart';
=======
>>>>>>> Stashed changes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  
  String? userId = await secureStorage.read(key: 'userId');
  
  runApp(MyApp(isLoggedIn: userId != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorConstant.darkBlue),
        useMaterial3: true,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          displayLarge: TextStyle(fontFamily: 'Poppins'),
          displayMedium: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      //home: SignupScreen(pageController: pageController),  // Pass the PageController here
      home: BottomNavBar(userId: 1, userType: 'Rider'),
      //home: ScannerScreen(),
    );
  }
}



