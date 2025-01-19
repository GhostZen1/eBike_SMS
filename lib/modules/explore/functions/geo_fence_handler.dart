import 'package:latlong2/latlong.dart';

import '../../global_import.dart';
import '../widget/custom_warning_border.dart';

class GeoFenceHandler {

  /// Determines if a point is on, near, or far from the geofence boundary.
  /// Returns:
  /// -1: On or outside the geofence boundary
  ///  0: Within [thresholdNear] meters of the geofence boundary
  ///  1: Inside the geofence and farther than [thresholdNear] meters
  static int checkPointInGeofence(
      LatLng point,
      List<LatLng> geofence,
      double thresholdNear, // Threshold for "near" geofence boundary
      ) {
    const Distance distance = Distance();

    bool isInside = _isPointInPolygon(point, geofence);
    double minDistanceToBoundary = double.infinity;

    // Check distance to each segment of the geofence
    for (int i = 0; i < geofence.length - 1; i++) {
      LatLng start = geofence[i];
      LatLng end = geofence[i + 1];

      LatLng closestPoint = _getClosestPointOnSegment(point, start, end);
      double distToSegment = distance(point, closestPoint);

      if (distToSegment < minDistanceToBoundary) {
        minDistanceToBoundary = distToSegment;
      }
    }

    // Logic for returning status
    if (!isInside || minDistanceToBoundary == 0) {
      return -1; // On or outside the geofence
    } else if (minDistanceToBoundary <= thresholdNear) {
      return 0; // Near the geofence boundary
    } else {
      return 1; // Inside and far from the geofence boundary
    }
  }


  /// Helper function to determine if a point is inside a polygon using the ray-casting algorithm
  static bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length - 1; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[i + 1];

      if (((p1.longitude > point.longitude) != (p2.longitude > point.longitude)) &&
          (point.latitude <
              (p2.latitude - p1.latitude) *
                  (point.longitude - p1.longitude) /
                  (p2.longitude - p1.longitude) +
                  p1.latitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // Odd number of intersections means inside
  }


  /// Helper function to get the closest point on a line segment
  static LatLng _getClosestPointOnSegment(LatLng point, LatLng start, LatLng end) {
    double x1 = start.latitude;
    double y1 = start.longitude;
    double x2 = end.latitude;
    double y2 = end.longitude;
    double px = point.latitude;
    double py = point.longitude;

    double dx = x2 - x1;
    double dy = y2 - y1;

    if (dx == 0 && dy == 0) {
      // The segment is a single point
      return start;
    }

    // Project point onto the segment
    double t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy);

    // Clamp t to the range [0, 1]
    t = t.clamp(0, 1);

    // Compute the closest point
    double closestLat = x1 + t * dx;
    double closestLng = y1 + t * dy;

    return LatLng(closestLat, closestLng);
  }


  static void showPopup(BuildContext context, bool isWarning) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 20,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            height: 100,
            child: PopupMessage(
              icon: Icons.warning_amber_rounded,
              iconColor: isWarning ? ColorConstant.yellow : ColorConstant.white,
              title: isWarning ? "You entering the border." : "BORDER CROSSED",
              message: isWarning
                  ? "Do not cross the marked borders. Violations will be reported."
                  : "Please return the bike to safe zone immediately.",
              backgroundColor:
              isWarning ? ColorConstant.white : ColorConstant.red,
              textColor: isWarning ? ColorConstant.black : ColorConstant.white,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}