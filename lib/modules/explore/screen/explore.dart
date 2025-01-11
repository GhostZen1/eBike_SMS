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
import 'package:http/http.dart' as http;
import 'dart:async'; // For Timer
import 'dart:convert'; // For jsonDecode

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}




class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  late List<dynamic> _allLocations;
  late List<dynamic> _allBikes;
  late ValueNotifier<LatLng> _currentUserLatLng = ValueNotifier(MapConstant.initCenterPoint);
  bool _isMarkersLoaded = false;

  @override
  void initState() {
    super.initState();
    SharedState.visibleMarkers.value.clear(); // Clear the markers before reinitializing again (avoid marker duplication)
    _fetchLandmarks();
    _fetchBikes();
    _fetchCurrentUserLocation();
    _startLocationUpdates();
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
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: ColorConstant.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstant.shadow,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                      spreadRadius: 0
                    )
                  ]
                ),
                child: const LoadingAnimation(dimension: 30),
              )
            )
          ),
        ],
      ),
    );
  }



  void _buildLandmarkMarkers() {
    if (_allLocations.isNotEmpty) {
      for (int i = 0; i < _allLocations.length; i++) {
        if (_allLocations[i]['latitude'] != null && _allLocations[i]['longitude'] != null) {
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
        if (_allBikes[i]['current_latitude'] != null && _allBikes[i]['current_longitude'] != null) {
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









//Coding Zu
//Untuk fetch location esp32

  Timer? _locationTimer;
  //bool _isMarkersLoaded = false;

  // Replace with the actual IP of your ESP32
  final String esp32Url = 'http://192.168.0.100/location';

  // Method to fetch ESP32 location
  Future<Map<String, double>> fetchESP32Location() async {
    try {
      final response = await http.get(Uri.parse(esp32Url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'latitude': double.parse(data['latitude']),
          'longitude': double.parse(data['longitude']),
        };
      } else {
        throw Exception('Failed to fetch location');
      }
    } catch (e) {
      print('Error fetching ESP32 location: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  void _buildCurrentMarkers(double latitude, double longitude) {
  //SharedState.bikeCurrentLatitude = latitude as ValueNotifier<double>;
  //SharedState.bikeCurrentLongitude = longitude as ValueNotifier<double>;
  SharedState.visibleMarkers.value.clear(); // Clear existing markers
  SharedState.visibleMarkers.value.add(
    CustomMarker.bike(
      index: 40,
      latitude: latitude,
      longitude: longitude,
      bikeStatus: "Test",
      onTap: () => _onTapCurrentMarker(latitude, longitude),
      // onTap: () {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text("Current Location: \nLatitude: $latitude\nLongitude: $longitude"),
      //       duration: const Duration(seconds: 3),
      //     ),
      //   );
      // },
    ),
  );

  setState(() {
    _isMarkersLoaded = true;
  });
}

   // Method to start periodic location updates
  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      final location = await fetchESP32Location();
      _buildCurrentMarkers(location['latitude']!, location['longitude']!);
    });
  }


//sampai sini











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
    var results = await LocationController.getLocations();
    if(results['status'] == 0) { // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${results['status']}, Message: ${results['message']}")),
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
    if(results['status'] == 0) { // Failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${results['status']}, Message: ${results['message']}")),
      );
    }
    _allBikes = results['data'];
    _buildBikeMarkers();
  }

  void _fetchCurrentUserLocation() async {
    if(getLocationPermission() == false) return;

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
          const SnackBar(content: Text('Location permissions are denied.')),
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
      setState(() {
        // Remove the old User marker
        SharedState.visibleMarkers.value.removeWhere((marker) => marker.key == const ValueKey("user_marker"));

        // Add the updated User marker
        SharedState.visibleMarkers.value.add(
            CustomMarker.user(
                latitude: _currentUserLatLng.value.latitude,
                longitude: _currentUserLatLng.value.longitude
            )
        );
      });
    }, onError: (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error receiving location updates: $e')),
      );
    });
  }

  void _updateRideMarkerRealTime() {
    if(SharedState.isRiding.value) {

    }
    // TODO: Make ride markers update in real time (needs IoT API)
  }

  void _onTapLocationMarker(int index) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.landmark;
    SharedState.landmarkNameMalay.value = _allLocations[index]['landmark_name_malay'];
    SharedState.landmarkNameEnglish.value = _allLocations[index]['landmark_name_english'];
    SharedState.landmarkType.value = _allLocations[index]['landmark_type'];
    SharedState.landmarkAddress.value = _allLocations[index]['address'];
    SharedState.landmarkLatitude.value = double.parse(_allLocations[index]['latitude']);
    SharedState.landmarkLongitude.value = double.parse(_allLocations[index]['longitude']);

    // Map animation when tapped
    animatePinpoint(LatLng(double.parse(_allLocations[index]['latitude']), double.parse(_allLocations[index]['longitude'])));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.markerCardVisibility.value = false;
    SharedState.markerCardVisibility.value = true;
    // This is not redundant code. (Though it can be improved)
  }

  void _onTapBikeMarker(int index) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.scanBike;
    SharedState.bikeId.value = _allBikes[index]['bike_id'];
    SharedState.bikeStatus.value = _allBikes[index]['status'];
    SharedState.bikeCurrentLatitude.value = double.parse(_allBikes[index]['current_latitude']) ;
    SharedState.bikeCurrentLongitude.value = double.parse(_allBikes[index]['current_longitude']);

    // Map animation when tapped
    animatePinpoint(LatLng(double.parse(_allBikes[index]['current_latitude']), double.parse(_allBikes[index]['current_longitude'])));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.markerCardVisibility.value = false;
    SharedState.markerCardVisibility.value = true;
    // This is not redundant code. (Though it can be improved)
  }








  void _onTapCurrentMarker(double latitude, double longitude) {
    // Update these values to make marker card visible and it's details
    SharedState.markerCardContent.value = MarkerCardContent.scanBike;
    SharedState.bikeId.value = "Latitude = $latitude, Longitude = $longitude";
    SharedState.bikeStatus.value = "Available";
    SharedState.bikeCurrentLatitude.value = latitude ;
    SharedState.bikeCurrentLongitude.value = longitude;

    // Map animation when tapped
    animatePinpoint(LatLng(latitude, longitude));
    animateRotation(0);

    // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
    SharedState.markerCardVisibility.value = false;
    SharedState.markerCardVisibility.value = true;
    // This is not redundant code. (Though it can be improved)
  }














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

