import 'dart:async';

import 'package:ebikesms/modules/explore/controller/bike_controller.dart';
import 'package:ebikesms/shared/utils/calculation.dart';
import 'package:ebikesms/shared/utils/shared_state.dart';

import '../../global_import.dart';
import '../sub-screen/navigation/screen/nav_destination.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;

import 'custom_marker.dart';

class MarkerCard extends StatefulWidget {
  final MarkerCardContent markerCardState;
  final bool isNavigating;
  final String bikeStatus;
  final String bikeId;
  final String currentTotalDistance;
  final String currentRideTime;
  final String landmarkNameMalay;
  final String landmarkNameEnglish;
  final String landmarkType;
  final String landmarkAddress;

  const MarkerCard({
    super.key,
    required this.markerCardState,
    this.isNavigating = false,
    // For bike marker cards:
    this.bikeStatus = "",
    this.bikeId = "",
    this.currentTotalDistance = "",
    this.currentRideTime = "",
    // For landmark marker cards:
    this.landmarkNameMalay = "",
    this.landmarkNameEnglish = "",
    this.landmarkType = "",
    this.landmarkAddress = "",
  });

  @override
  State<MarkerCard> createState() => _MarkerCardState();
}

class _MarkerCardState extends State<MarkerCard> {
  late double cardWidth;
  late double cardHeight;

  @override
  Widget build(BuildContext context) {
    cardWidth = MediaQuery.of(context).size.width * 0.9;
    cardHeight = 245;
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.only(bottom: 50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: ColorConstant.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(color: ColorConstant.shadow, blurRadius: 4.0, offset: Offset(0, 2)),
        ],
      ),
      child: Builder(
        builder: (context) {
          switch (widget.markerCardState) {
            case MarkerCardContent.loading:
              return _displayLoadingContent();
            case MarkerCardContent.scanBike:
              return _displayScanBikeContent();
            case MarkerCardContent.confirmBike:
              return _displayConfirmBikeContent();
            case MarkerCardContent.ridingBike:
              return _displayRidingBikeContent();
            case MarkerCardContent.warningBike:
              return _displayWarningBikeContent();
            case MarkerCardContent.landmark:
              return _displayLandmarkContent();
            default:
              return const SizedBox.shrink();
          }
        }
      )
    );
  }

  Widget _displayLoadingContent (){
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoadingAnimation(dimension: 45),
        SizedBox(height: 30)
      ],
    );
  }


  Widget _displayScanBikeContent() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
              child: CustomIcon.bicycle(70, color: ColorConstant.black),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Bike ID ",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: ColorConstant.black),
                      ),
                      Text(
                        widget.bikeId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ColorConstant.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomIcon.bikeStatus(14, widget.bikeStatus),
                      const SizedBox(width: 5),
                      AutoSizeText(
                        widget.bikeStatus,
                        maxFontSize: 12,
                        minFontSize: 11,
                        style: const TextStyle(color: ColorConstant.black),

                      ),
                      const Spacer(),
                      Visibility(
                        visible: (widget.bikeStatus == "Available"),
                        child: const AutoSizeText(
                          TextConstant.priceRateLabel,
                          maxFontSize: 12,
                          minFontSize: 11,
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: CustomRectangleButton(
                          height: 35,
                          label: "Ring",
                          fontSize: 12,
                          enable: (widget.bikeStatus == "Available"),
                          fontWeight: FontWeight.w600,
                          backgroundColor: ColorConstant.white,
                          foregroundColor: ColorConstant.darkBlue,
                          
                          borderSide: const BorderSide(width: 2, color: ColorConstant.darkBlue),
                          onPressed: () async {
                            final esp8266Ip = "192.168.164.53"; // Replace with your ESP8266 IP
                            final url = Uri.parse('http://$esp8266Ip/ring');

                            try {
                              final response = await http.get(url);

                              if (response.statusCode == 200) {
                                print("Bike is ringing!");
                              } else {
                                print("Failed to ring the bike. Status code: ${response.statusCode}");
                              }
                            } catch (e) {
                              print("Error: $e");
                            }
                          },
                        ),
                      ),
                    ],

                  )
                ],
              )
            ),
          ],
        ),
        const Spacer(flex: 1),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              (widget.bikeStatus == "Available") ? "Get near the bike" : "Bike is unavailable",
              style: TextStyle(
                fontSize: 12,
                color: (widget.bikeStatus == "Available") ? ColorConstant.black : ColorConstant.red,
              ),
            ),
            Text(
              (widget.bikeStatus == "Available") ? "Scan the bike" : "Look for another bike",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: (widget.bikeStatus == "Available") ? ColorConstant.darkBlue : ColorConstant.grey,
              ),
            ),
          ],
        ),
        const Spacer(flex: 3),
      ],
    );
  }


  Widget _displayConfirmBikeContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
              child: CustomIcon.bicycle(70, color: ColorConstant.black),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Bike ID ",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: ColorConstant.black),
                      ),
                      Text(
                        widget.bikeId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ColorConstant.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomIcon.bikeStatus(14, widget.bikeStatus),
                      const SizedBox(width: 3),
                      AutoSizeText(
                        widget.bikeStatus,
                        maxFontSize: 12,
                        minFontSize: 11,
                        style: const TextStyle(color: ColorConstant.black),
                      ),
                      const Spacer(),
                      (widget.bikeStatus == "Available")
                          ? const Text(
                        TextConstant.priceRateLabel,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        (widget.bikeStatus == 'Available')
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: ColorConstant.black),
                      children: [
                        const TextSpan(text: "Start riding with "),
                        TextSpan(
                          text: widget.bikeId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: "?"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: CustomRectangleButton(
                          height: 45,
                          label: "Cancel",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          backgroundColor: ColorConstant.white,
                          foregroundColor: ColorConstant.darkBlue,
                          borderSide: const BorderSide(width: 2, color: ColorConstant.darkBlue),
                          onPressed: () {
                            SharedState.markerCardVisibility.value = false;
                          },
                        ),
                      ),
                      const SizedBox(width: 10), // The gap between buttons
                      Expanded(
                        child: CustomRectangleButton(
                          height: 45,
                          label: "Confirm",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          backgroundColor: ColorConstant.darkBlue,
                          foregroundColor: ColorConstant.white,
                          onPressed: () {
                            _confirmRideSession();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
            : const Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 13),
                Text(
                  "This bike is unavailable",
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorConstant.red,
                  ),
                ),
                Text(
                  "Look for another bike",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConstant.grey,
                  ),
                ),
              ],
            ),
      ],
    );
  }


  void _confirmRideSession() async {
    // Set loading content while waiting to fetch bike data
    SharedState.markerCardVisibility.value = false; // Purposely make it false first in order to see change
    SharedState.markerCardVisibility.value = true;
    SharedState.markerCardContent.value = MarkerCardContent.loading;
    
    // Fetch bike data
    var results = await BikeController.getSingleBikeData(widget.bikeId);
    if (results['status'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${results['status']}, Message: ${results['message']}")),
      );
      return;
    }
    double parsedLat = double.parse(results['data'][0]['current_latitude']);
    double parsedLong = double.parse(results['data'][0]['current_longitude']);

    // Assign the start location (latlong)
    SharedState.bikeCurrentLatitude.value = parsedLat;
    SharedState.bikeCurrentLongitude.value = parsedLong;

    // TODO: Get bike can get distance
    // TODO: Deduct the current session with ride time available
    // SharedState.currentTotalDistance.value =  // TODO: Get updates in increments from ebike for the actual distance travel

    // Start timer for ride time
    int rideTimeValue = 0;
    SharedState.timer.value = Timer.periodic(const Duration(minutes: 1), (timer) {
      rideTimeValue++;
      String rideTimeStr = Calculation.convertMinuteToShortRideTime(rideTimeValue);
      SharedState.currentRideTime.value = rideTimeStr;
    });

    // Assign the start ride time, will be uploaded when end session occurs
    SharedState.rideStartDatetime.value = await Calculation.getCurrentDateTime();

    // Set riding bike content for the marker card
    SharedState.markerCardVisibility.value = false; // Purposely make it false first in order to see change
    SharedState.markerCardVisibility.value = true;
    SharedState.markerCardContent.value = MarkerCardContent.ridingBike;
    SharedState.isRiding.value = true;
    if(SharedState.cachedMarkers.value.isEmpty) {
      SharedState.cachedMarkers.value.addAll(SharedState.visibleMarkers.value);
    }
    SharedState.visibleMarkers.value.clear();
    SharedState.visibleMarkers.value.add(
      CustomMarker.riding(
        latitude: parsedLat,
        longitude: parsedLong,
      ),
    );
  }


  Widget _displayRidingBikeContent() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
              child: CustomIcon.bicycle(70, color: ColorConstant.black),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Bike ID ",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: ColorConstant.black),
                      ),
                      Text(
                        widget.bikeId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ColorConstant.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomIcon.bikeStatus(14, widget.bikeStatus),
                      const SizedBox(width: 3),
                      AutoSizeText(
                        widget.bikeStatus,
                        maxFontSize: 12,
                        minFontSize: 11,
                        style: const TextStyle(color: ColorConstant.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ValueListenableBuilder(
                    valueListenable: SharedState.isNavigating, // Assuming SharedState.isNavigating is a ValueNotifier<bool>
                    builder: (context, isNavigating, child) {
                      return CustomRectangleButton(
                        height: 35,
                        label: isNavigating ? "End Navigation" : "Start Navigation",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        backgroundColor: isNavigating ? ColorConstant.white : ColorConstant.darkBlue,
                        foregroundColor: isNavigating ? ColorConstant.darkBlue : ColorConstant.white,
                        borderSide: isNavigating
                            ? const BorderSide(width: 3, color: ColorConstant.darkBlue)
                            : BorderSide.none,
                        onPressed: () {
                          if (isNavigating) {
                            _endNavigation();
                          } else {
                            _startNavigation();
                          }
                        },
                      );
                    },
                  ),
                ],
              )
            ),
          ],
        ),
        const Spacer(flex: 1),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Column(
                children: [
                  CustomIcon.distance(40, color: ColorConstant.black),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 50,
                    child: AutoSizeText(
                      widget.currentTotalDistance,
                      maxLines: 1,
                      minFontSize: 8,
                      maxFontSize: 12,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: ColorConstant.shadow,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            const AutoSizeText.rich(
              textAlign: TextAlign.center,
              maxFontSize: 13,
              minFontSize: 11,
              TextSpan(
                style: TextStyle(
                    color: ColorConstant.darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),
                children: [
                  TextSpan(text: "Your ongoing\n"),
                  TextSpan(
                    text: "   session",
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: ColorConstant.shadow,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Column(
                children: [
                  CustomIcon.clock(30, color: ColorConstant.black),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 50,
                    child: ValueListenableBuilder(
                      valueListenable: SharedState.currentRideTime,
                      builder: (context, rideTime, widget) {
                        return AutoSizeText(
                          rideTime, // "1h 43m",
                          maxLines: 1,
                          minFontSize: 8,
                          maxFontSize: 12,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const Spacer(flex: 5),
      ],
    );
  }

  Widget _displayWarningBikeContent() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
              child: CustomIcon.bicycle(70, color: ColorConstant.black),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Bike ID ",
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: ColorConstant.black),
                      ),
                      Text(
                        widget.bikeId,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ColorConstant.black),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomIcon.bikeStatus(14, widget.bikeStatus),
                      const SizedBox(width: 3),
                      AutoSizeText(
                        widget.bikeStatus,
                        maxFontSize: 12,
                        minFontSize: 11,
                        style: const TextStyle(color: ColorConstant.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ValueListenableBuilder(
                    valueListenable: SharedState.isNavigating, // Assuming SharedState.isNavigating is a ValueNotifier<bool>
                    builder: (context, isNavigating, child) {
                      return CustomRectangleButton(
                        height: 35,
                        label: isNavigating ? "End Navigation" : "Start Navigation",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        backgroundColor: isNavigating ? ColorConstant.white : ColorConstant.darkBlue,
                        foregroundColor: isNavigating ? ColorConstant.darkBlue : ColorConstant.white,
                        borderSide: isNavigating
                            ? const BorderSide(width: 3, color: ColorConstant.darkBlue)
                            : BorderSide.none,
                        onPressed: () {
                          if (isNavigating) {
                            _endNavigation();
                          } else {
                            _startNavigation();
                          }
                        },
                      );
                    },
                  ),
                ],
              )
            ),
          ],
        ),
        const Spacer(flex: 1),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Column(
                children: [
                  CustomIcon.distance(40, color: ColorConstant.red),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 50,
                    child: AutoSizeText(
                      widget.currentTotalDistance,
                      maxLines: 1,
                      minFontSize: 8,
                      maxFontSize: 12,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ColorConstant.red
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: ColorConstant.shadow,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            const AutoSizeText.rich(
              textAlign: TextAlign.center,
              maxFontSize: 13,
              minFontSize: 11,
              TextSpan(
                style: TextStyle(
                    color: ColorConstant.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13
                ),
                children: [
                  TextSpan(text: "Please return\n"), // First line
                  TextSpan(
                    text: "  to safe zone", // Indented second line
                  ),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: ColorConstant.shadow,
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Column(
                children: [
                  CustomIcon.clock(30, color: ColorConstant.red),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 50,
                    child: SizedBox(
                      width: 50,
                      child: ValueListenableBuilder(
                        valueListenable: SharedState.currentRideTime,
                        builder: (context, rideTime, widget) {
                          return AutoSizeText(
                            rideTime, // "1h 43m",
                            maxLines: 1,
                            minFontSize: 8,
                            maxFontSize: 12,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        const Spacer(flex: 6),
      ],
    );
  }

  Widget _displayLandmarkContent() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 25, 0),
              child: CustomIcon.landmarkMarker(60, widget.landmarkType),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 0, // Wraps content
                      maxHeight: 50,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: AutoSizeText(
                        widget.landmarkNameMalay,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ColorConstant.black),
                        minFontSize: 14,
                      ),
                    ),
                  ),
                  Scrollbar(
                    thickness: 1,
                    radius: const Radius.circular(50),
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: AutoSizeText(
                        widget.landmarkNameEnglish,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: ColorConstant.black),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
        const Spacer(flex: 1),
        Container(
          padding: const EdgeInsets.fromLTRB(4, 13, 4, 5),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 70,
                child: AutoSizeText(
                  widget.landmarkType,
                  minFontSize: 13,
                  maxFontSize: 14,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 70,
                padding: const EdgeInsets.only(right: 5),
                margin: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                color: ColorConstant.shadow,
              ),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      widget.landmarkAddress,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
        const Spacer(flex: 8),
      ],
    );
  }

  void _startNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NavDestinationScreen()),
    );
  }

  void _endNavigation() {
    setState(() {
      if (SharedState.isNavigating.value) {
        SharedState.isNavigating.value = false;
        SharedState.routePoints.value = [];
        SharedState.visibleMarkers.value
            .removeWhere((marker) => (marker.key == const ValueKey("pinpoint_marker")));
        SharedState.visibleMarkers.value
            .removeWhere((marker) => (marker.key as ValueKey).value.toString().startsWith("landmark_marker_"));
      }
    });
  }
}