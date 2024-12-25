import 'package:ebikesms/modules/explore/widget/marker_card.dart';
import 'package:ebikesms/modules/qr_scanner/screen/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:ebikesms/modules/admin/report/screen/incident_report.dart';
import 'package:ebikesms/modules/admin/revenue/screen/revenue.dart';
import 'package:ebikesms/modules/admin/menu.dart';


import '../constants/app_constants.dart';
import '../../modules/explore/screen/explore.dart';
import '../../modules/menu/screen/menu.dart';
import '../utils/calculation.dart';
import '../utils/custom_icon.dart';
import '../utils/shared_state.dart';


class BottomNavBar extends StatefulWidget {
  final int userId;
  final int userType;

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
  late int _selectedNavIndex = 0;
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
            IndexedStack(
              index: _selectedNavIndex,
              children: const [
                ExploreScreen(),
                SizedBox.shrink(), // This is a dummy widget that exists BELOW middle rounded button
                MenuScreen()
              ],
            ),

            // Marker Card
            ValueListenableBuilder<bool>(
              valueListenable: SharedState.markerCardVisibility,
              builder: (context, visible, _) {
                return Visibility(
                  visible: visible,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: SharedState.markerCardVisibility.value && (SharedState.markerCardContent.value != MarkerCardContent.ridingBike && SharedState.markerCardContent.value != MarkerCardContent.warningBike),
                        child: TextButton(
                          onPressed: (){ SharedState.markerCardVisibility.value = false; },
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
                        currentTotalDistance: SharedState.currentTotalDistance.value,
                        currentRideTime: SharedState.currentRideTime.value,
                        // Location marker cards:
                        locationNameMalay: SharedState.locationNameMalay.value,
                        locationNameEnglish: SharedState.locationNameEnglish.value,
                        locationType: SharedState.locationType.value,
                        address: SharedState.address.value,
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
                      currentIndex: _selectedNavIndex,
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
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        if(SharedState.isRiding.value) {
                          _endRideSession();
                        }
                        else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context)=> QRScannerScreen())
                          );
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
                    const SizedBox(height: 3),
                    SizedBox(
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
                    const SizedBox(height: 34),
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
    if (index != _selectedNavIndex) {
      setState(() {
        _selectedNavIndex = index;
        if(index != 0) {
          temp = SharedState.markerCardVisibility.value;
          SharedState.markerCardVisibility.value = false;
        }
        else {
          SharedState.markerCardVisibility.value = temp;
        }
      });
      // _pageController.jumpToPage(index);
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

  void _endRideSession() async {
    SharedState.isRiding.value = false;
    SharedState.markerCardVisibility.value = false;
    SharedState.markerCardContent.value = MarkerCardContent.scanBike;
    SharedState.rideEndDatetime.value = await Calculation.getCurrentDateTime();

    SharedState.visibleMarkers.value.clear();
    SharedState.visibleMarkers.value.addAll(SharedState.cachedMarkers.value);

    // Reset the timer for current ride time
    SharedState.timer.value?.cancel();
    SharedState.currentRideTime.value = "< 1 minute";

    // Reset the timer for current ride time
    SharedState.timer.value?.cancel();
    SharedState.currentTotalDistance.value = "< 1 meter";

    // TODO: Reset the total current distance

    // TODO: Post ride and bike data (start and end datetime) to the database
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
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    _navBarWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _bottomNavChildrenWidget().elementAt(_selectedNavIndex),
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
                      currentIndex: _selectedNavIndex,
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
    if (index != _selectedNavIndex) {
      setState(() {
        _selectedNavIndex = index;
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
      IncidentReportScreen(),    // Replace with your Report screen
      MenuScreen(),      // Replace with your Menu screen
    ];
  }
}

