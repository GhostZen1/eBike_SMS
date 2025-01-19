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




class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  late List<dynamic> _allLandmarkData;
  late List<dynamic> _allBikeData;
  late ValueNotifier<LatLng> _currentUserLatLng = ValueNotifier(MapConstant.initCenterPoint);
  bool _isMarkersLoaded = false;

  @override
  void initState() {
    super.initState();
    SharedState.visibleMarkers.value.clear(); // Clear the markers before reinitializing again (avoid marker duplication)
    _fetchLandmarks();
    _fetchBikes();
    _fetchCurrentUserLocation();
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
                          mapController: SharedState.mainMapController.value,
                          initialCenter: MapConstant.initCenterPoint,
                          initialZoom: MapConstant.initZoomLevel,
                          enableInteraction: true,
                          allMarkers: SharedState.visibleMarkers.value,
                          routePoints: SharedState.routePoints.value
                        );
                      },
                    );
                  }
              );
            }
          ),

          // Map Side Buttons
          ValueListenableBuilder(
            valueListenable: SharedState.isRiding,
            builder: (context, isRiding, _) {
              if(isRiding){
                animatePinpoint(LatLng(SharedState.bikeCurrentLatitude.value, SharedState.bikeCurrentLongitude.value));
                animateRotation(0.0);
              }
              return MapSideButtons(
                mapController: SharedState.mainMapController.value,
                locationToPinpoint: (isRiding)
                    ? LatLng(SharedState.bikeCurrentLatitude.value, SharedState.bikeCurrentLongitude.value)
                    : _currentUserLatLng.value,
                showGuideButton: true
              );
            },
          ),

          // Loading Animation
          Visibility(
            visible: !_isMarkersLoaded,
            child: const LoadingAnimation(dimension: 30, enableBackground: true),
          ),
        ],
      ),
    );
  }


  // Marker One-time Building
  void _buildLandmarkMarkers() {
    if (_allLandmarkData.isNotEmpty) {
      for (int i = 0; i < _allLandmarkData.length; i++) {
        if (_allLandmarkData[i]['latitude'] != null && _allLandmarkData[i]['longitude'] != null) {
          double parsedLat = double.parse(_allLandmarkData[i]['latitude']);
          double parsedLong = double.parse(_allLandmarkData[i]['longitude']);
          SharedState.visibleMarkers.value.add(
            CustomMarker.landmark(
              index: i,
              latitude: parsedLat,
              longitude: parsedLong,
              landmarkType: _allLandmarkData[i]['landmark_type'],
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
    if (_allBikeData.isNotEmpty) {
      for (int i = 0; i < _allBikeData.length; i++) {
        if (_allBikeData[i]['current_latitude'] != null && _allBikeData[i]['current_longitude'] != null) {
          double parsedLat = double.parse(_allBikeData[i]['current_latitude']);
          double parsedLong = double.parse(_allBikeData[i]['current_longitude']);
          // Ignoring bikes that have "Riding" status
          if (_allBikeData[i]['status'] != "Riding") {
            SharedState.visibleMarkers.value.add(
              CustomMarker.bike(
                index: i,
                latitude: parsedLat,
                longitude: parsedLong,
                bikeStatus: _allBikeData[i]['status'],
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


  // Marker onTap Behaviours
  void _onTapLocationMarker(int index) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.landmark;
    SharedState.landmarkNameMalay.value = _allLandmarkData[index]['landmark_name_malay'];
    SharedState.landmarkNameEnglish.value = _allLandmarkData[index]['landmark_name_english'];
    SharedState.landmarkType.value = _allLandmarkData[index]['landmark_type'];
    SharedState.landmarkAddress.value = _allLandmarkData[index]['address'];
    SharedState.landmarkLatitude.value = double.parse(_allLandmarkData[index]['latitude']);
    SharedState.landmarkLongitude.value = double.parse(_allLandmarkData[index]['longitude']);

    // Map animation when tapped
    animatePinpoint(LatLng(double.parse(_allLandmarkData[index]['latitude']), double.parse(_allLandmarkData[index]['longitude'])));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.enableMarkerCard.value = false;
    SharedState.enableMarkerCard.value = true;
    // This is not redundant code. (Though it can be improved)
  }

  void _onTapBikeMarker(int index) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.scanBike;
    SharedState.bikeId.value = _allBikeData[index]['bike_id'];
    SharedState.bikeStatus.value = _allBikeData[index]['status'];
    SharedState.bikeCurrentLatitude.value = double.parse(_allBikeData[index]['current_latitude']) ;
    SharedState.bikeCurrentLongitude.value = double.parse(_allBikeData[index]['current_longitude']);

    // Map animation when tapped
    animatePinpoint(LatLng(double.parse(_allBikeData[index]['current_latitude']), double.parse(_allBikeData[index]['current_longitude'])));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.enableMarkerCard.value = false;
    SharedState.enableMarkerCard.value = true;
    // This is not redundant code. (Though it can be improved)
  }


  // Marker Data Fetching
  void _fetchLandmarks() async {
    setState(() {
      _isMarkersLoaded = false;
    });
    var results = await LandmarkController.getLandmarks();
    if(results['status'] == 0) { // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${results['status']}, Message: ${results['message']}")),
      );
    }
    _allLandmarkData = results['data'];
    _buildLandmarkMarkers();
  }

  void _fetchBikes() async {
    setState(() {
      _isMarkersLoaded = false;
    });
    var results = await BikeController.getAllBikeData();
    if(results['status'] == 0) { // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${results['status']}, Message: ${results['message']}")),
      );
    }
    _allBikeData = results['data'];
    _buildBikeMarkers();
  }


  // User location permission, fetching, and real-time update
  void _fetchCurrentUserLocation() async {
    if(await getLocationPermission() == false) return;

    // Fetch user's initial location
    try {
      setState(() {
        _isMarkersLoaded = false;
      });
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      _currentUserLatLng.value = currentLatLng;
      _buildUserMarker();
      _updateUserRealTime();
    }
    catch (e) {
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
        const SnackBar(content: Text('Location permissions are permanently denied.')),
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
      // Remove the old User marker
      SharedState.visibleMarkers.value.removeWhere((marker) => marker.key == const ValueKey("user_marker"));

      // Add the updated User marker
      SharedState.visibleMarkers.value.add(
          CustomMarker.user(
              latitude: _currentUserLatLng.value.latitude,
              longitude: _currentUserLatLng.value.longitude
          )
      );
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error receiving location updates: $e')),
      );
    });
  }


  // Map Animations
  void animatePinpoint(LatLng target) {
    // Set the duration of the animation
    const duration = Duration(milliseconds: 500); // 1 second for a smoother transition

    // Create an AnimationController
    final controller = AnimationController(vsync: this, duration: duration);

    // Add a CurvedAnimation to apply a smooth curve to the animation
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    // Define the Tween for each property (latitude, longitude, and zoom)
    final latTween = Tween<double>(begin: SharedState.mainMapController.value.camera.center.latitude, end: target.latitude);
    final lngTween = Tween<double>(begin: SharedState.mainMapController.value.camera.center.longitude, end: target.longitude);
    final zoomTween = Tween<double>(begin: SharedState.mainMapController.value.camera.zoom, end: MapConstant.focusZoomLevel); // Adjusts zoom

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
    const duration = Duration(milliseconds: 300); // Duration for animation (adjust as needed)

    // Create an AnimationController with the current vsync (usually this in StatefulWidget)
    final controller = AnimationController(vsync: this, duration: duration);

    // Define a CurvedAnimation for smooth easing
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    // Get the current rotation of the map
    final currentRotation =  SharedState.mainMapController.value.camera.rotation;

    // Define a Tween to animate the rotation from current rotation to target rotation
    final rotationTween = Tween<double>(begin: currentRotation, end: targetRotation);

    // Add a listener to update the map's rotation as the animation progresses
    controller.addListener(() {
      final rotation = rotationTween.evaluate(curve);
      SharedState.mainMapController.value.rotate(rotation);  // Update the map's rotation
    });

    // Start the animation and dispose of the controller once done
    controller.forward().whenComplete(() {
      controller.dispose();
    });
  }
}

