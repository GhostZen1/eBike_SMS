import 'package:ebikesms/modules/explore/widget/marker_card.dart';
import 'package:ebikesms/modules/qr_scanner/screen/scanner_page.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
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
  final PageController _pageController = PageController();
  final SharedState _sharedState = SharedState();
  late final double _labelSize = 11;
  late double _navBarWidth;
  late final double _navBarHeight = 60;
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    // _navBarWidth is placed here due to "MediaQuery" requires build context to get screen width
    _navBarWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            bottomNavChildrenWidget().elementAt(_selectedNavIndex),
            ValueListenableBuilder<bool>(
              valueListenable: _sharedState.markerCardVisibility,
              builder: (context, visible, _) {
                return Visibility(
                  visible: _sharedState.markerCardVisibility.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: (){ _sharedState.markerCardVisibility.value = false; },
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
                      MarkerCard(
                        markerCardState: _sharedState.markerCardState.value,
                        navigationButtonEnable: _sharedState.navigationButtonEnable.value,
                        // Bike marker cards:
                        bikeStatus: _sharedState.bikeStatus.value,
                        bikeId: _sharedState.bikeId.value,
                        currentTotalDistance: _sharedState.currentTotalDistance.value,
                        currentRideTime: _sharedState.currentRideTime.value,
                        // Location marker cards:
                        locationNameMalay: _sharedState.locationNameMalay.value,
                        locationNameEnglish: _sharedState.locationNameEnglish.value,
                        locationType: _sharedState.locationType.value,
                        address: _sharedState.address.value,
                      ),
                    ],
                  )
                );
              }
            ),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0), // To adjust the touch animation corner radius
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
                  )
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context)=> ScannerScreen())
                          );
                      },
                      child: Builder(
                        builder: (context) {
                          switch(_sharedState.markerCardState.value) {
                            case MarkerCardState.ridingBike:
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
                            case MarkerCardState.warningBike:
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
                      child: Builder(
                        builder: (context) {
                          switch(_sharedState.markerCardState.value) {
                            case MarkerCardState.warningBike:
                              return SizedBox(height: _labelSize + 4);
                            case MarkerCardState.ridingBike:
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
          temp = _sharedState.markerCardVisibility.value;
          _sharedState.markerCardVisibility.value = false;
        }
        else {
          _sharedState.markerCardVisibility.value = temp;
        }
      });
      _pageController.jumpToPage(index);
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

  List<Widget> bottomNavChildrenWidget() {
    return [
      ExploreScreen(_sharedState),
      ScannerScreen(),
      const MenuScreen(),
      // MenuScreen(_sharedState), // TODO: Uncomment this and delete the line above
    ];
  }
}


// User type: Admin
// User type: Admin
// User type: Admin
class _BottomNavBarAdmin extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError(); // TODO: implement build
  }
}
