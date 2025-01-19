import 'package:auto_size_text/auto_size_text.dart';
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/modules/menu/widget/icon_card.dart';
import 'package:ebikesms/modules/menu/widget/menu_tile.dart';
import 'package:ebikesms/shared/utils/calculation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage dependency
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ebikesms/ip.dart';
import 'package:ebikesms/shared/constants/app_constants.dart';
import 'package:ebikesms/shared/utils/custom_icon.dart';

import 'package:ebikesms/modules/menu/sub-menu/time_top_up/screen/time_top_up.dart';
import 'package:ebikesms/modules/menu/sub-menu/ride_history/screen/ride_history.dart';
import 'package:ebikesms/modules/menu/sub-menu/settings/screen/policy.dart';
import 'package:ebikesms/modules/menu/sub-menu/settings/screen/about.dart';
import 'package:ebikesms/modules/learn/screen/learn.dart';
import 'package:ebikesms/modules/menu/widget/logout_modal.dart';
import 'package:ebikesms/modules/menu/sub-menu/user_report/user_report.dart';

import '../../../shared/utils/shared_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late int userId = 0;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedState.isAvailableRideTimeNewest.value = false;
    try {
      // Retrieve the user ID from secure storage
      String? userIdString = await _secureStorage.read(key: 'userId');
      userId = int.tryParse(userIdString ?? "0") ?? 0;

      if (userIdString != null) {
        // Fetch user data from the API using the user_id
        final response = await http.get(
          Uri.parse('${ApiBase.baseUrl}/get_user_id.php?user_id=$userIdString'),
        );

        if (response.statusCode == 200) {
          print('Response Body: ${response.body}'); // Print the raw response
          try {
            final responseBody = json.decode(response.body);

            if (responseBody['status'] == 'success') {
              setState(() {
                _userData = responseBody['data'];
                SharedState.availableRideTime.value = _userData?['available_ride_time'];
                SharedState.isAvailableRideTimeNewest.value = true;
              });
            } else {
              throw Exception(
                  'Failed to fetch user data: ${responseBody['message']}');
            }
          } catch (e) {
            print('Error decoding JSON: $e');
          }
        } else {
          throw Exception('Failed to load user data');
        }
      } else {
        print("User ID not found in secure storage");
      }
    } catch (e) {
      // Handle errors (e.g., show a dialog or log)
      print('Error loading user data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.hintBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: ColorConstant.red,
                  child: CustomIcon.userColoured(40),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData?['user_name'] ??
                          'Loading...', // Updated to match API response
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData?['matric_number'] ??
                          'Loading...', // Ensure this key exists in API
                      style: const TextStyle(color: ColorConstant.grey),
                    ),
                    SizedBox(
                      width: 220, // Adjust the width as needed
                      child: AutoSizeText(
                        _userData?['user_email'] ?? 'Loading...', // Ensure this key exists in API
                        maxFontSize: 14,
                        minFontSize: 10,
                        maxLines: 1,
                        style: const TextStyle(color: ColorConstant.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Available Ride Time Section
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Positioned Button ("+ Add More")
                  GestureDetector(
                    onTap: () async {
                      bool isTimeAdded = false;
                      try{
                        isTimeAdded = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeTopUpScreen(
                              userId: userId,
                            ),
                          ),
                        );

                        // Refresh the user data if any result is returned
                        if(isTimeAdded) _fetchUserData();
                      }
                      catch (e) {
                        print("Error in navigation: $e"); // Debug 3
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 185,
                      decoration: BoxDecoration(
                        color: ColorConstant.shadowdarkBlue, // Darker blue color
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "+ Add More",
                              style: TextStyle(
                                color: ColorConstant.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top card with ride time information
                  Positioned(
                    top: -10,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 145,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: ColorConstant.darkBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Ride Time Header
                          Row(
                            children: [
                              CustomIcon.clock(20, color: ColorConstant.white),
                              const SizedBox(width: 10),
                              const Text(
                                'AVAILABLE RIDE TIME',
                                style: TextStyle(
                                  color: ColorConstant.white,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1.0,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Ride Time Value
                          ValueListenableBuilder(
                            valueListenable: SharedState.isAvailableRideTimeNewest,
                            builder: (_, isNewest, __) {
                              return ValueListenableBuilder(
                                  valueListenable: SharedState.availableRideTime,
                                  builder: (_, rideTime, __) {
                                    return (!isNewest)
                                        ? const LoadingAnimation(dimension: 30)
                                        : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: AutoSizeText(
                                        (rideTime == 0)
                                            ? 'Empty Balance.'
                                            : Calculation.convertMinutesToLongRideTime(rideTime),
                                        maxFontSize: 28,
                                        minFontSize: 24,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          letterSpacing: 1.0,
                                          fontWeight: FontWeight.bold,
                                          color: ColorConstant.white,
                                        ),
                                      ),
                                    );
                                  }
                              );
                            }
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: IconCard(
                    iconWidget:
                        CustomIcon.bicycle(50, color: ColorConstant.black),
                    label: 'Ride History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RideHistoryScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15), // Add spacing between cards
                Expanded(
                  child: IconCard(
                    iconWidget: CustomIcon.learnColoured(50),
                    label: 'Learn how to use',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LearnScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ExpansionMenuTile(
                    label: "Settings",
                    iconWidget:
                        CustomIcon.settings(24, color: ColorConstant.darkBlue),
                    enableForwardArrow: true,
                    children: [
                      // ListTile(
                      //   title: const Text(
                      //     "Account",
                      //     style: TextStyle(
                      //       color: ColorConstant.grey,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const AccountSettingsScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),
                      MenuTile(
                        label: "Policy",
                        labelColor: ColorConstant.grey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PolicyScreen(),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        label: "About",
                        labelColor: ColorConstant.grey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                    ]),
                MenuTile(
                  label: "Report",
                  iconWidget: CustomIcon.report(
                    22,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserReportScreen(),
                      ),
                    );
                  },
                ),
                MenuTile(
                  label: "Log out",
                  labelColor: ColorConstant.red,
                  iconWidget: CustomIcon.logout(22, color: ColorConstant.red),
                  onTap: () {
                    logoutModal(context);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
