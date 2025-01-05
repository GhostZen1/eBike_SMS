import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/utils/custom_icon.dart';

class CustomMarker extends Marker{
  CustomMarker({required super.point, required super.child});

  // Singular Markers (User and riding)
  static Marker user({
    required double latitude,
    required double longitude})
  {
    return Marker(
      key: const ValueKey("user_marker"),
      width: 20,
      height: 20,
      point: LatLng(latitude, longitude),
      child: CustomIcon.userMarker(1),
    );
  }


  // Singular Markers (User and riding)
  static Marker riding({
    required double latitude,
    required double longitude,
    VoidCallback? onTap})
  {
    return Marker(
      key: const ValueKey("riding_marker"),
      width: 35,
      height: 35,
      point: LatLng(latitude, longitude),
      child: CustomIcon.ridingMarker(1),
    );
  }

  // Location-pointing Markers with duplication with different ValueKeys (Landmarks & Bikes)
  static Marker landmark({
    required double latitude,
    required double longitude,
    required String landmarkType,
    int index = 0,
    VoidCallback? onTap,
    double dimension = 35})
  {
    return Marker(
      key: ValueKey("landmark_marker_$index"),
      width: dimension,
      height: dimension,
      point: LatLng(latitude, longitude),
      child: Transform.translate(
        offset: Offset(0, -dimension / 2),
        child: GestureDetector(
          onTap: onTap,
          child: CustomIcon.landmarkMarker(1, landmarkType),
        ),
      ),
    );
  }


  // Location-pointing Markers with duplication with different ValueKeys (Landmarks & Bikes)
  static Marker bike({
    required double latitude,
    required double longitude,
    required String bikeStatus,
    int index = 0,
    VoidCallback? onTap,
    double dimension = 38})
  {
    return Marker(
      key: ValueKey("bike_marker_$index"),
      width: dimension,
      height: dimension,
      point: LatLng(latitude, longitude),
      child: Transform.translate(
        offset: Offset(0, -dimension / 2),
        child: GestureDetector(
          onTap: onTap,
          child: CustomIcon.bikeMarker(1, bikeStatus),
        ),
      ),
    );
  }

  // Location-pointing Markers, singular (Pinpoint marker)
  static Marker pinpoint({
    required double latitude,
    required double longitude,
    VoidCallback? onTap,
    double dimension = 35})
  {
    return Marker(
      key: const ValueKey("pinpoint_marker"),
      width: dimension,
      height: dimension,
      point: LatLng(latitude, longitude),
      child: Transform.translate(
        offset: Offset(0, -dimension / 2),
        child: GestureDetector(
          onTap: onTap,
          child: CustomIcon.pinpointColoured(1),
        ),
      ),
    );
  }
}