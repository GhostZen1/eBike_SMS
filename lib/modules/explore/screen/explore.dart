import 'dart:core';

import 'package:ebikesms/modules/explore/controller/bike_controller.dart';
import 'package:ebikesms/modules/explore/widget/custom_marker.dart';
import 'package:ebikesms/modules/explore/widget/map_side_buttons.dart';
import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/shared/utils/shared_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../controller/landmark_controller.dart';
import '../widget/custom_map.dart';
import 'dart:async';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  late List<dynamic> _allLocations;
  late List<dynamic> _allBikes;
  late List<dynamic> _singleBikes;
  late ValueNotifier<LatLng> _currentUserLatLng =
      ValueNotifier(MapConstant.initCenterPoint);
  bool _isMarkersLoaded = false;

  @override
  void initState() {
    super.initState();
    SharedState.visibleMarkers.value
        .clear(); // Clear the markers before reinitializing again (avoid marker duplication)
    _fetchLandmarks();
    _fetchBikes();
    _fetchCurrentUserLocation();

    Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchCurrentBike();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Custom map
          ValueListenableBuilder(
              valueListenable: SharedState.isRiding,
              builder: (context, _, __) {
                return ValueListenableBuilder(
                    valueListenable: SharedState.visibleMarkers,
                    builder: (context, _, __) {
                      return ValueListenableBuilder(
                        valueListenable: SharedState.routePoints,
                        builder: (context, _, __) {
                          return CustomMap(
                              mapController:
                                  SharedState.mainMapController.value,
                              initialCenter: MapConstant.initCenterPoint,
                              initialZoom: MapConstant.initZoomLevel,
                              enableInteraction: true,
                              allMarkers: SharedState.visibleMarkers.value,
                              routePoints: SharedState.routePoints.value);
                        },
                      );
                    });
              }),

          // Map Side Buttons
          ValueListenableBuilder(
            valueListenable: SharedState.isRiding,
            builder: (context, isRiding, _) {
              if (isRiding) {
                animatePinpoint(LatLng(SharedState.bikeCurrentLatitude.value,
                    SharedState.bikeCurrentLongitude.value));
                animateRotation(0.0);
              }
              return MapSideButtons(
                  mapController: SharedState.mainMapController.value,
                  locationToPinpoint: (isRiding)
                      ? LatLng(SharedState.bikeCurrentLatitude.value,
                          SharedState.bikeCurrentLongitude.value)
                      : _currentUserLatLng.value,
                  showGuideButton: true);
            },
          ),

          // Loading Animation
          Visibility(
            visible: !_isMarkersLoaded,
            child:
                const LoadingAnimation(dimension: 30, enableBackground: true),
          ),
        ],
      ),
    );
  }

  void _buildLandmarkMarkers() {
    if (_allLocations.isNotEmpty) {
      for (int i = 0; i < _allLocations.length; i++) {
        if (_allLocations[i]['latitude'] != null &&
            _allLocations[i]['longitude'] != null) {
          double parsedLat = double.parse(_allLocations[i]['latitude']);
          double parsedLong = double.parse(_allLocations[i]['longitude']);
          SharedState.visibleMarkers.value.add(
            CustomMarker.landmark(
              index: i,
              latitude: parsedLat,
              longitude: parsedLong,
              landmarkType: _allLocations[i]['landmark_type'],
              onTap: () => _onTapLocationMarker(i),
            ),
          );
        }
      }
    }
    setState(() {
      _isMarkersLoaded = true;
    });
  }

  void _buildBikeMarkers() {
    if (_allBikes.isNotEmpty) {
      for (int i = 0; i < _allBikes.length; i++) {
        if (_allBikes[i]['current_latitude'] != null &&
            _allBikes[i]['current_longitude'] != null) {
          double parsedLat = double.parse(_allBikes[i]['current_latitude']);
          double parsedLong = double.parse(_allBikes[i]['current_longitude']);
          // Ignoring bikes that have "Riding" status
          if (_allBikes[i]['status'] != "Riding") {
            SharedState.visibleMarkers.value.add(
              CustomMarker.bike(
                index: i,
                latitude: parsedLat,
                longitude: parsedLong,
                bikeStatus: _allBikes[i]['status'],
                onTap: () => _onTapBikeMarker(i),
              ),
            );
          }
        }
      }
    }
    setState(() {
      _isMarkersLoaded = true;
    });
  }

  void _buildUserMarker() {
    SharedState.visibleMarkers.value.add(
      CustomMarker.user(
        latitude: _currentUserLatLng.value.latitude,
        longitude: _currentUserLatLng.value.longitude,
      ),
    );
    setState(() {
      _isMarkersLoaded = true;
    });
  }

  void _fetchLandmarks() async {
    setState(() {
      _isMarkersLoaded = false;
    });
    var results = await LandmarkController.getLandmarks();
    if (results['status'] == 0) {
      // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Status: ${results['status']}, Message: ${results['message']}")),
      );
    }
    _allLocations = results['data'];
    _buildLandmarkMarkers();
  }

  void _fetchBikes() async {
    setState(() {
      _isMarkersLoaded = false;
    });
    var results = await BikeController.getAllBikeData();
    if (results['status'] == 0) {
      // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Status: ${results['status']}, Message: ${results['message']}")),
      );
    }
    _allBikes = results['data'];
    _buildBikeMarkers();
  }

  void _fetchCurrentBike() async {
    String bikeId = "B25001";
    var results = await BikeController.fetchSingleBike(bikeId);
    if (results['status'] == 0) {
      // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Status: ${results['status']}, Message: ${results['message']}")),
      );
    }
    _singleBikes = results['data'];
    _updateRideMarkerRealTime();
  }

  // void _updateRideMarkerRealTime() {
  //   if (_singleBikes.isNotEmpty) {
  //     for (int i = 0; i < _singleBikes.length; i++) {
  //       if (_singleBikes[i]['current_latitude'] != null &&
  //           _singleBikes[i]['current_longitude'] != null) {
  //         double parsedLat = double.parse(_singleBikes[i]['current_latitude']);
  //         double parsedLong =
  //             double.parse(_singleBikes[i]['current_longitude']);

  //         setState(() {
  //           // Remove the old ride marker
  //           SharedState.visibleMarkers.value.removeWhere(
  //               (marker) => marker.key == const ValueKey("riding_marker"));

  //           // Add the new ride marker
  //           SharedState.visibleMarkers.value.add(
  //             CustomMarker.riding(
  //               latitude: parsedLat,
  //               longitude: parsedLong,
  //               // onTap: () => _onTapBikeMarker(i),
  //             ),
  //           );
  //         });
  //       }
  //     }
  //   }
  // }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayIntersectsSegment(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // Odd => inside; Even => outside
  }

  bool _rayIntersectsSegment(LatLng point, LatLng vertex1, LatLng vertex2) {
    double px = point.latitude;
    double py = point.longitude;
    double v1x = vertex1.latitude;
    double v1y = vertex1.longitude;
    double v2x = vertex2.latitude;
    double v2y = vertex2.longitude;

    if ((py > v1y && py > v2y) ||
        (py < v1y && py < v2y) ||
        (px > v1x && px > v2x)) {
      return false;
    }
    if (px < v1x && px < v2x) {
      return true;
    }
    double m = (v2y - v1y) / (v2x - v1x);
    double xIntersect = (py - v1y) / m + v1x;
    return px < xIntersect;
  }

  void _updateRideMarkerRealTime() {
    if (_singleBikes.isNotEmpty) {
      for (int i = 0; i < _singleBikes.length; i++) {
        if (_singleBikes[i]['current_latitude'] != null &&
            _singleBikes[i]['current_longitude'] != null) {
          double parsedLat = double.parse(_singleBikes[i]['current_latitude']);
          double parsedLong =
              double.parse(_singleBikes[i]['current_longitude']);

          LatLng currentLocation = LatLng(parsedLat, parsedLong);

          // Check if the current location is within the geofence
          bool isInsideGeofence =
              _isPointInPolygon(currentLocation, MapConstant.geoFencePoints);

          if (!isInsideGeofence) {
            // Handle out-of-bound logic
            _handleOutOfBound(i, currentLocation);
          }

          setState(() {
            // Remove the old ride marker
            SharedState.visibleMarkers.value.removeWhere(
                (marker) => marker.key == ValueKey("riding_marker_$i"));

            // Add the new ride marker
            SharedState.visibleMarkers.value.add(
              CustomMarker.riding(
                latitude: parsedLat,
                longitude: parsedLong,
                // color: isInsideGeofence
                //     ? Colors.green
                //     : Colors.red, // Optional color update
                // onTap: () => _onTapBikeMarker(i),
              ),
            );
          });
        }
      }
    }
  }

  void _handleOutOfBound(int bikeIndex, LatLng currentLocation) {
    print("Bike $bikeIndex is out of bounds at $currentLocation");
  }

  void _fetchCurrentUserLocation() async {
    if (await getLocationPermission() == false) return;

    // Fetch user's initial location
    try {
      setState(() {
        _isMarkersLoaded = false;
      });
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      _currentUserLatLng.value = currentLatLng;
      _buildUserMarker();
      _updateUserRealTime();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user location: $e')),
      );
    }
  }

  Future<bool> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Check location services and permissions
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are disabled.')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return false;
    }
    return true;
  }

  void _updateUserRealTime() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Minimum movement to trigger an update
      ),
    ).listen((Position position) {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      _currentUserLatLng.value = currentLatLng;
      setState(() {
        // Remove the old User marker
        SharedState.visibleMarkers.value.removeWhere(
            (marker) => marker.key == const ValueKey("user_marker"));

        // Add the updated User marker
        SharedState.visibleMarkers.value.add(CustomMarker.user(
            latitude: _currentUserLatLng.value.latitude,
            longitude: _currentUserLatLng.value.longitude));
      });
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error receiving location updates: $e')),
      );
    });
  }

  void _onTapLocationMarker(int index) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.landmark;
    SharedState.landmarkNameMalay.value =
        _allLocations[index]['landmark_name_malay'];
    SharedState.landmarkNameEnglish.value =
        _allLocations[index]['landmark_name_english'];
    SharedState.landmarkType.value = _allLocations[index]['landmark_type'];
    SharedState.landmarkAddress.value = _allLocations[index]['address'];
    SharedState.landmarkLatitude.value =
        double.parse(_allLocations[index]['latitude']);
    SharedState.landmarkLongitude.value =
        double.parse(_allLocations[index]['longitude']);

    // Map animation when tapped
    animatePinpoint(LatLng(double.parse(_allLocations[index]['latitude']),
        double.parse(_allLocations[index]['longitude'])));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.enableMarkerCard.value = false;
    SharedState.enableMarkerCard.value = true;
    // This is not redundant code. (Though it can be improved)
  }

  void _onTapBikeMarker(int index) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.scanBike;
    SharedState.bikeId.value = _allBikes[index]['bike_id'];
    SharedState.bikeStatus.value = _allBikes[index]['status'];
    SharedState.bikeCurrentLatitude.value =
        double.parse(_allBikes[index]['current_latitude']);
    SharedState.bikeCurrentLongitude.value =
        double.parse(_allBikes[index]['current_longitude']);

    // Map animation when tapped
    animatePinpoint(LatLng(double.parse(_allBikes[index]['current_latitude']),
        double.parse(_allBikes[index]['current_longitude'])));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.enableMarkerCard.value = false;
    SharedState.enableMarkerCard.value = true;
    // This is not redundant code. (Though it can be improved)
  }

  void animatePinpoint(LatLng target) {
    // Set the duration of the animation
    const duration =
        Duration(milliseconds: 500); // 1 second for a smoother transition

    // Create an AnimationController
    final controller = AnimationController(vsync: this, duration: duration);

    // Add a CurvedAnimation to apply a smooth curve to the animation
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    // Define the Tween for each property (latitude, longitude, and zoom)
    final latTween = Tween<double>(
        begin: SharedState.mainMapController.value.camera.center.latitude,
        end: target.latitude);
    final lngTween = Tween<double>(
        begin: SharedState.mainMapController.value.camera.center.longitude,
        end: target.longitude);
    final zoomTween = Tween<double>(
        begin: SharedState.mainMapController.value.camera.zoom,
        end: MapConstant.focusZoomLevel); // Adjusts zoom

    // Listen for the animation progress
    controller.addListener(() {
      final lat = latTween.evaluate(curve);
      final lng = lngTween.evaluate(curve);
      final zoomLevel = zoomTween.evaluate(curve);

      // Move the map to the animated position and zoom level
      SharedState.mainMapController.value.move(LatLng(lat, lng), zoomLevel);
    });

    // Start the animation and dispose of the controller once it's done
    controller.forward().whenComplete(() {
      controller.dispose();
    });
  }

  void animateRotation(double targetRotation) {
    const duration = Duration(
        milliseconds: 300); // Duration for animation (adjust as needed)

    // Create an AnimationController with the current vsync (usually this in StatefulWidget)
    final controller = AnimationController(vsync: this, duration: duration);

    // Define a CurvedAnimation for smooth easing
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    // Get the current rotation of the map
    final currentRotation = SharedState.mainMapController.value.camera.rotation;

    // Define a Tween to animate the rotation from current rotation to target rotation
    final rotationTween =
        Tween<double>(begin: currentRotation, end: targetRotation);

    // Add a listener to update the map's rotation as the animation progresses
    controller.addListener(() {
      final rotation = rotationTween.evaluate(curve);
      SharedState.mainMapController.value
          .rotate(rotation); // Update the map's rotation
    });

    // Start the animation and dispose of the controller once done
    controller.forward().whenComplete(() {
      controller.dispose();
    });
  }
}
