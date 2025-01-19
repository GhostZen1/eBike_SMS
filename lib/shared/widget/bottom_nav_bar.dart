import 'package:ebikesms/modules/explore/widget/end_ride_modal.dart';
import 'package:ebikesms/modules/explore/widget/marker_card.dart';
import 'package:ebikesms/modules/qr_scanner/screen/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:ebikesms/modules/admin/report/screen/report.dart';
import 'package:ebikesms/modules/admin/revenue/screen/revenue.dart';


import '../constants/app_constants.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../modules/explore/screen/explore.dart';
import '../../modules/menu/screen/menu.dart';
import '../utils/custom_icon.dart';
import '../utils/shared_state.dart';


class BottomNavBar extends StatefulWidget {
  final int userId;
  final String userType;

  const BottomNavBar({
    super.key,
    required this.userId,
    required this.userType, // TODO: userType
  });

  @override
  State<BottomNavBar> createState() {
    if(userType == 'Rider') {
      return _BottomNavBarRider();  // If it's 'rider', show rider state
    }
    else { // If it's 'admin', show admin state
      return _BottomNavBarAdmin();
    }
  }
}

// User type: Rider
// User type: Rider
// User type: Rider
class _BottomNavBarRider extends State<BottomNavBar> {
  late final double _labelSize = 11;
  late final double _navBarHeight = 60;
  late double _navBarWidth;

  @override
  Widget build(BuildContext context) {
    // _navBarWidth is placed here due to "MediaQuery" requires build context to get screen width
    _navBarWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Explore and Menu content (Scanner is accessed in the rounded button)
            ValueListenableBuilder(
              valueListenable: SharedState.selectedNavIndex,
              builder: (_, selectedIndex, __) {
                return IndexedStack(
                  index: selectedIndex,
                  children: const [
                    ExploreScreen(),
                    SizedBox.shrink(), // This is a dummy widget that exists BELOW middle rounded button
                    MenuScreen()
                  ],
                );
              }
            ),

            // Marker Card
            ValueListenableBuilder<bool>(
              valueListenable: SharedState.enableMarkerCard,
              builder: (context, visible, _) {
                return Visibility(
                  visible: visible,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: SharedState.enableMarkerCard.value && (SharedState.markerCardContent.value != MarkerCardContent.ridingBike && SharedState.markerCardContent.value != MarkerCardContent.warningBike),
                        child: TextButton(
                          onPressed: (){ SharedState.enableMarkerCard.value = false; },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: ColorConstant.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: ColorConstant.grey,
                                offset: Offset(0, 0),
                                blurRadius: 2
                              )]
                            ),
                            child: CustomIcon.close(10, color: ColorConstant.grey)
                          )
                        ),
                      ),
                      MarkerCard(
                        markerCardState: SharedState.markerCardContent.value,
                        isNavigating: SharedState.isNavigating.value,
                        // Bike marker cards:
                        bikeStatus: SharedState.bikeStatus.value,
                        bikeId: SharedState.bikeId.value,
                        currentRideDistance: SharedState.currentRideDistance.value,
                        currentRideDuration: SharedState.currentRideDuration.value,
                        // Location marker cards:
                        landmarkNameMalay: SharedState.landmarkNameMalay.value,
                        landmarkNameEnglish: SharedState.landmarkNameEnglish.value,
                        landmarkType: SharedState.landmarkType.value,
                        landmarkAddress: SharedState.landmarkAddress.value,
                      ),
                    ],
                  )
                );
              }
            ),

            // The bottom nav bar
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              fit: StackFit.passthrough,
              children: [
                Container(
                  height: _navBarHeight,
                  width: _navBarWidth,
                  constraints: BoxConstraints(
                    maxWidth: _navBarWidth,
                    minWidth: 200,
                  ),
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: ColorConstant.white,
                    borderRadius: BorderRadius.circular(15.0), // To adjust the white box corner radius
                    boxShadow: const [
                      BoxShadow(color: ColorConstant.shadow, blurRadius: 4.0, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ClipRRect(  // To adjust the touch animation corner radius
                    borderRadius: BorderRadius.circular(15.0),
                    child: BottomNavigationBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      selectedItemColor: ColorConstant.darkBlue,
                      selectedLabelStyle: TextStyle(fontSize: _labelSize, fontWeight: FontWeight.w600),
                      unselectedItemColor: ColorConstant.black,
                      unselectedLabelStyle: TextStyle(fontSize: _labelSize, fontWeight: FontWeight.normal),
                      currentIndex: SharedState.selectedNavIndex.value,
                      showUnselectedLabels: true,
                      items: _bottomNavigationBarItems(),
                      onTap: _onItemTapped,
                    )
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // For blocking the center nav bar item Scan/Close button
                        Container(
                          color: Colors.transparent,
                          width: 120,
                          height: 60,
                        ),
                        // The floating round scan button
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          onPressed: () async {
                            if(SharedState.isRiding.value) {
                              EndRideModal(context);
                            }
                            else {
                              final status = await Permission.camera.request();
                              if (status.isGranted) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)=> QRScannerScreen())
                                );
                              } else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Camera permission is denied. Please enable it in settings.')),
                                );
                                openAppSettings();
                              }
                            }
                          },
                          child: ValueListenableBuilder(
                            valueListenable: SharedState.markerCardContent,
                            builder: (context, markerCardState, child) {
                              switch(markerCardState) {
                                case MarkerCardContent.ridingBike:
                                  return Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: ColorConstant.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ColorConstant.red,
                                          width: 3,
                                        ),
                                      ),
                                      child: CustomIcon.close(24, color: ColorConstant.red)
                                  );
                                case MarkerCardContent.warningBike:
                                  return Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        color: ColorConstant.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CustomIcon.warning(28, color: ColorConstant.white)
                                  );
                                default:
                                  return Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                        color: ColorConstant.darkBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CustomIcon.qrScanner(28, color: ColorConstant.white)
                                  );
                              }
                            },
                          )
                        ),
                      ],
                    ),
                    Container( // Blocker for scan/close label
                      color: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 34),
                      width: 120,
                      child: ValueListenableBuilder(
                        valueListenable: SharedState.markerCardContent,
                        builder: (context, markerState, widget) {
                          switch(markerState) {
                            case MarkerCardContent.warningBike:
                              return SizedBox(height: _labelSize + 4);
                            case MarkerCardContent.ridingBike:
                              return Text(
                                "End ride",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _labelSize, color: ColorConstant.red, fontWeight: FontWeight.bold),
                              );
                            default:
                              return Text(
                                "Scan",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: _labelSize),
                              );
                          }
                        },
                      )
                    ),
                  ],
                )
              ],
            ),
          ],
        )
      ),
    );
  }

  bool temp = false;
  void _onItemTapped(int index) {
    if (index != SharedState.selectedNavIndex.value) {
      setState(() {
        SharedState.selectedNavIndex.value = index;
        if(index != 0) {
          temp = SharedState.enableMarkerCard.value;
          SharedState.enableMarkerCard.value = false;
        }
        else {
          if(SharedState.markerCardContent.value == MarkerCardContent.loading) temp = false;
          SharedState.enableMarkerCard.value = temp;
        }
      });
    }
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(
        label: 'Explore',
        icon: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: CustomIcon.location(22, color: ColorConstant.black)
        ),
        activeIcon: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: CustomIcon.location(22, color: ColorConstant.darkBlue)
        ),
      ),
      const BottomNavigationBarItem(
        icon: SizedBox.shrink(),
        label: '',
      ),
      BottomNavigationBarItem(
        label: 'Menu',
        icon: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: CustomIcon.menu(23, color: ColorConstant.black)
        ),
        activeIcon: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: CustomIcon.menu(23, color: ColorConstant.darkBlue)
        ),
      ),
    ];
  }
}


// User type: Admin
// User type: Admin
// User type: Admin
class _BottomNavBarAdmin extends State<BottomNavBar> {
  final PageController _pageController = PageController();
  late final double _labelSize = 11;
  late double _navBarWidth;
  late final double _navBarHeight = 60;

  @override
  Widget build(BuildContext context) {
    _navBarWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _bottomNavChildrenWidget().elementAt(SharedState.selectedNavIndex.value),
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              fit: StackFit.passthrough,
              children: [
                Container(
                  height: _navBarHeight,
                  width: _navBarWidth,
                  constraints: BoxConstraints(
                    maxWidth: _navBarWidth,
                    minWidth: 200,
                  ),
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: ColorConstant.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: const [
                      BoxShadow(color: ColorConstant.shadow, blurRadius: 4.0, offset: Offset(0, 2)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: BottomNavigationBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      selectedItemColor: ColorConstant.darkBlue,
                      selectedLabelStyle: TextStyle(fontSize: _labelSize, fontWeight: FontWeight.w600),
                      unselectedItemColor: ColorConstant.black,
                      unselectedLabelStyle: TextStyle(fontSize: _labelSize, fontWeight: FontWeight.normal),
                      currentIndex: SharedState.selectedNavIndex.value,
                      showUnselectedLabels: true,
                      items: _bottomNavigationBarItems(),
                      onTap: _onItemTapped,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index != SharedState.selectedNavIndex.value) {
      setState(() {
        SharedState.selectedNavIndex.value = index;
      });
      _pageController.jumpToPage(index);
    }
  }

  List<BottomNavigationBarItem> _bottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(
        label: 'Statistic',
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: CustomIcon.statistic(22, color: ColorConstant.black),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: CustomIcon.statistic(22, color: ColorConstant.darkBlue),
        ),
      ),
      BottomNavigationBarItem(
        label: 'Report',
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: CustomIcon.warning(22, color: ColorConstant.black),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: CustomIcon.warning(22, color: ColorConstant.darkBlue),
        ),
      ),
      BottomNavigationBarItem(
        label: 'Menu',
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: CustomIcon.menu(23, color: ColorConstant.black),
        ),
        activeIcon: Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: CustomIcon.menu(23, color: ColorConstant.darkBlue),
        ),
      ),
    ];
  }

  List<Widget> _bottomNavChildrenWidget() {
    return [
      RevenueScreen(), // Replace with your Statistic screen
      ReportScreen(),    // Replace with your Report screen
      MenuScreen(),      // Replace with your Menu screen
    ];
  }
}

