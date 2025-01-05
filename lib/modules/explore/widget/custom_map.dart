import 'package:latlong2/latlong.dart';

import '../../global_import.dart';

class CustomMap extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final bool enableInteraction;
  final List<Marker> allMarkers;
  final List<LatLng>? routePoints;

  const CustomMap({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.initialZoom,
    required this.enableInteraction,
    required this.allMarkers,
    this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        interactionOptions: InteractionOptions(
          flags: (enableInteraction)
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        ),
        PolygonLayer(
          polygons: [
            Polygon(
              points: MapConstant.theWholeWorld,
              holePointsList: [MapConstant.geoFencePoints],
              color: ColorConstant.hintBlue.withOpacity(0.6), // Fill color with opacity
              borderColor: Colors.blue, // Border color
              borderStrokeWidth: 1,
            ),
          ],
        ),
        if (routePoints?.isNotEmpty ?? false)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints!,
                color: ColorConstant.skyBlue,
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(markers: allMarkers),
      ],
    );
  }
}
