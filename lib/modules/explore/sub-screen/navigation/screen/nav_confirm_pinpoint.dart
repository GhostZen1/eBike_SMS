import 'package:ebikesms/modules/explore/widget/custom_marker.dart';
import 'package:ebikesms/modules/explore/widget/custom_map.dart';
import 'package:ebikesms/modules/explore/widget/map_side_buttons.dart';
import 'package:ebikesms/shared/utils/calculation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../../../../shared/utils/shared_state.dart';
import '../../../../global_import.dart';

class NavConfirmPinpointScreen extends StatefulWidget {
  final List<dynamic> allLocations;
  const NavConfirmPinpointScreen({
    super.key,
    required this.allLocations
  });

  @override
  State<NavConfirmPinpointScreen> createState() => _NavConfirmPinpointScreenState();
}

class _NavConfirmPinpointScreenState extends State<NavConfirmPinpointScreen> {
  final MapController _mapController = MapController();
  final ValueNotifier<LatLng> _currentUserLatLng = ValueNotifier(MapConstant.initCenterPoint); // Initialize with default value
  bool _isMarkersLoaded = false;
  late LatLng bikeLocation;
  late List<Marker> _navMarkers = [];
  late List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _buildLandmarkMarkers();
    _fetchCurrentUserLocation();
    bikeLocation = LatLng(SharedState.bikeCurrentLatitude.value, SharedState.bikeCurrentLongitude.value);
  }

  Future<void> _fetchRouteFromOSRM(LatLng start, LatLng end) async {
    final String osrmUrl = 'https://router.project-osrm.org/route/v1/bike/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline';

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String encodedPolyline = data['routes'][0]['geometry'];

        SharedState.routePoints.value = Calculation.decodePolyline(encodedPolyline);
      }
      else {
        throw Exception('Failed to fetch route: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  void _buildLandmarkMarkers() {
    if (widget.allLocations.isNotEmpty) {
      for (int i = 0; i < widget.allLocations.length; i++) {
        if (widget.allLocations[i]['latitude'] != null && widget.allLocations[i]['longitude'] != null) {
          double parsedLat = double.parse(widget.allLocations[i]['latitude']);
          double parsedLong = double.parse(widget.allLocations[i]['longitude']);
          _navMarkers.add(
            CustomMarker.landmark(
              index: i,
              latitude: parsedLat,
              longitude: parsedLong,
              landmarkType: widget.allLocations[i]['landmark_type'],
            ),
          );
        }
      }
    }
    setState(() {
      _isMarkersLoaded = true;
    });
  }

  void _buildRidingMarker() {
    _navMarkers.add(
      CustomMarker.riding(
        latitude: SharedState.bikeCurrentLatitude.value,
        longitude: SharedState.bikeCurrentLongitude.value,
      ),
    );
    setState(() {
      _isMarkersLoaded = true;
    });
  }

  void _fetchCurrentUserLocation() async {
    if(getLocationPermission() == false) return;
    try {
      setState(() {
        _isMarkersLoaded = false;
      });
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      _currentUserLatLng.value = currentLatLng;
      _buildRidingMarker();
      //_updateUserRealTime();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Custom map display
          ValueListenableBuilder<LatLng>(
            valueListenable: _currentUserLatLng, // Listen to the ValueNotifier
            builder: (context, _, __) {
              return CustomMap(
                mapController: _mapController,
                initialCenter: MapConstant.initCenterPoint,
                initialZoom: MapConstant.initZoomLevel,
                enableInteraction: true,
                allMarkers: _navMarkers,
              );
            },
          ),

          // Back button
          const Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                        child: CustomCircularBackButton()
                    ),
                  ],
                ),
              ],
            )
          ),

          // Map Side Buttons
          MapSideButtons(
              mapController: _mapController,
              locationToPinpoint: LatLng(SharedState.bikeCurrentLatitude.value, SharedState.bikeCurrentLongitude.value),
              showGuideButton: false
          ),

          // Markers on the map (using the same
          Center(
            child: (_isMarkersLoaded)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Transform.translate(
                      offset: const Offset(0, -35 / 2),
                      child: CustomIcon.pinpointColoured(35)
                  ),
              )
              : Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: ColorConstant.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: ColorConstant.shadow,
                      offset: Offset(0, 2),
                      blurRadius: 10.0,
                      spreadRadius: 0.0
                    )
                  ]
                ),
              child: const LoadingAnimation(dimension: 30),
            )
          ),

          // Confirm button
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(40, 10, 40, 30),
                child: CustomRectangleButton(
                  label: "Confirm",
                  onPressed: () {
                    _confirmPinpoint();
                  },
                )
              )
            ],
          ),
      ])
    );
  }

  void _confirmPinpoint() {
    // Remove the landmark markers from the temporary marker list
    _navMarkers.removeWhere(
          (marker) => (marker.key as ValueKey).value.toString().startsWith("landmark_marker_"),
    );

    // Add the pinpoint marker to the temporary marker list
    _navMarkers.add(
      CustomMarker.pinpoint(
        latitude: _mapController.camera.center.latitude,
        longitude: _mapController.camera.center.longitude,
      ),
    );
    
    _fetchRouteFromOSRM(bikeLocation, _mapController.camera.center);
    SharedState.visibleMarkers.value.clear();
    SharedState.visibleMarkers.value.addAll(_navMarkers);  // Add the temporary markers here
    SharedState.isNavigating.value = true;
    SharedState.routePoints.value = _routePoints;
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
