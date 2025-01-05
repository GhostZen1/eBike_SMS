import 'package:ebikesms/modules/explore/widget/custom_map.dart';
import 'package:ebikesms/modules/explore/widget/custom_marker.dart';
import 'package:ebikesms/modules/explore/widget/marker_card.dart';
import 'package:ebikesms/shared/utils/calculation.dart';
import 'package:ebikesms/shared/widget/bottom_nav_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../../../../shared/utils/shared_state.dart';
import '../../../../global_import.dart';

class NavConfirmSelectedScreen extends StatefulWidget {
  final Map<String, dynamic> selectedLandmark;
  const NavConfirmSelectedScreen({
    super.key, 
    required this.selectedLandmark
  });

  @override
  State<NavConfirmSelectedScreen> createState() =>
      _NavConfirmSelectedScreenState();
}

class _NavConfirmSelectedScreenState extends State<NavConfirmSelectedScreen> {
  final _mapController = MapController();
  bool _isNotLoaded = true;
  late double _selectedLat;
  late double _selectedLong;
  late List<Marker> _navMarkers = [];
  late List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _selectedLat = double.parse(widget.selectedLandmark['latitude']);
    _selectedLong = double.parse(widget.selectedLandmark['longitude']);

    // Draw the route
    LatLng selectedDestination = LatLng(_selectedLat, _selectedLong);
    LatLng bikeLocation = LatLng(SharedState.bikeCurrentLatitude.value, SharedState.bikeCurrentLongitude.value);
    _fetchRouteFromOSRM(bikeLocation, selectedDestination);

    _buildSelectedLandmarkMarker();
    _buildRideMarker();
  }

  Future<void> _fetchRouteFromOSRM(LatLng start, LatLng end) async {
    setState(() {
      _isNotLoaded = true; // Show loading animation
    });

    final osrmUrl = 'https://router.project-osrm.org/route/v1/bike/'
        '${start.longitude},${start.latitude};'
        '${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline';

    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final encodedPolyline = data['routes'][0]['geometry'] as String;

        // Decode polyline and update SharedState
        _routePoints = Calculation.decodePolyline(encodedPolyline);
      } else {
        throw Exception('Failed to fetch route: HTTP ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching route: $error');
    } finally {
      setState(() {
        _isNotLoaded = false; // Hide loading animation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Map background
          ValueListenableBuilder(
            valueListenable: SharedState.routePoints,
            builder: (context, _, __) {
              return CustomMap(
                mapController: _mapController,
                initialCenter: MapConstant.initCenterPoint,
                initialZoom: MapConstant.initZoomLevel,
                enableInteraction: true,
                allMarkers: _navMarkers,
                routePoints: _routePoints,
              );
            }
          ),

          // Back Button
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          _exitScreen();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: ColorConstant.white, // Background color
                          shadowColor: ColorConstant.lightGrey, // Box shadow color
                          elevation: 3,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: CustomIcon.back(25, color: ColorConstant.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
          )),

          // Loading Animation (if markers is not loaded yet)
          Visibility(
            visible: _isNotLoaded, // Show only when fetching route
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: ColorConstant.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstant.shadow, // Shadow color
                      offset: Offset(0, 2),        // Shadow position
                      blurRadius: 10.0,           // Blur effect
                      spreadRadius: 0.0           // Spread radius
                    )
                  ],
                ),
                child: const LoadingAnimation(dimension: 30),
              ),
            ),
          ),


          // Location Marker Card
          MarkerCard(
            markerCardState: MarkerCardContent.landmark,
            landmarkNameMalay: widget.selectedLandmark['landmark_name_malay'],
            landmarkNameEnglish: widget.selectedLandmark['landmark_name_english'],
            landmarkType: widget.selectedLandmark['landmark_type'],
            landmarkAddress: widget.selectedLandmark['address'],
          ),

          // Confirm Button
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            margin: const EdgeInsets.fromLTRB(40, 10, 40, 30),
            child: CustomRectangleButton(
              label: "Confirm",
              enable: !_isNotLoaded,
              onPressed: () {
                _confirmNavigation();
              },
            )
          )
        ]
      )
    );
  }

  void _buildRideMarker() {
    _navMarkers.add(
      CustomMarker.riding(
        latitude: SharedState.bikeCurrentLatitude.value,
        longitude: SharedState.bikeCurrentLongitude.value
      )
    );
    setState(() {
      _isNotLoaded = true;
    });
  }

  void _buildSelectedLandmarkMarker() {
    _navMarkers.add(
      CustomMarker.landmark(
        latitude: _selectedLat,
        longitude: _selectedLong,
        landmarkType: widget.selectedLandmark['landmark_type']
      )
    );
    setState(() {
      _isNotLoaded = true;
    });
  }

  void _confirmNavigation() {
    SharedState.visibleMarkers.value.clear();
    SharedState.visibleMarkers.value.addAll(_navMarkers);
    SharedState.isNavigating.value = true;
    SharedState.routePoints.value = _routePoints;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _exitScreen() {
    SharedState.routePoints.value = [];
    Navigator.pop(context);
  }
}
