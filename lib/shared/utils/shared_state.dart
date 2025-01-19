import 'dart:async';

import 'package:ebikesms/modules/explore/widget/custom_marker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../modules/global_import.dart';
import '../constants/app_constants.dart';

class SharedState {
  // App related
  static ValueNotifier<int> selectedNavIndex = ValueNotifier(0);

  // Map related
  static ValueNotifier<bool> isNavigating = ValueNotifier(false);
  static ValueNotifier<bool> isRiding = ValueNotifier(false);
  static ValueNotifier<List<LatLng>> routePoints = ValueNotifier([]);
  static ValueNotifier<List<Marker>> visibleMarkers = ValueNotifier([]);
  static ValueNotifier<List<Marker>> cachedMarkers = ValueNotifier([]);
  static ValueNotifier<List<Marker>> landmarkMarkers = ValueNotifier([]);
  static ValueNotifier<List<Marker>> bikeMarkers = ValueNotifier([]);
  static ValueNotifier<Marker> userMarker = ValueNotifier(CustomMarker.user(latitude: 0, longitude: 0));
  static ValueNotifier<Marker> ridingMarker = ValueNotifier(CustomMarker.riding(latitude: 0, longitude: 0));
  static ValueNotifier<MapController> mainMapController = ValueNotifier(MapController());

  // Marker card related
  static ValueNotifier<bool> enableMarkerCard = ValueNotifier(false);
  static ValueNotifier<MarkerCardContent> markerCardContent = ValueNotifier(MarkerCardContent.scanBike);

  // Bike related
  static ValueNotifier<String> bikeId = ValueNotifier("");
  static ValueNotifier<String> bikeStatus = ValueNotifier("");
  static ValueNotifier<double> bikeCurrentLatitude = ValueNotifier(double.minPositive);
  static ValueNotifier<double> bikeCurrentLongitude = ValueNotifier(double.minPositive);

  // User related
  static ValueNotifier<bool> isAvailableRideTimeNewest = ValueNotifier(false);
  static ValueNotifier<int> availableRideTime = ValueNotifier(0);

  // Ride related
  static ValueNotifier<Timer?> rideTimer = ValueNotifier<Timer?>(null);
  static ValueNotifier<String> currentTotalDistance = ValueNotifier("< 1 meter"); // In km/m format
  static ValueNotifier<String> currentRideDuration = ValueNotifier("< 1 minute");  // In "xh xm" format
  static ValueNotifier<String> rideStartDatetime = ValueNotifier(""); // In DATETIME format 1999-12-31 00:00:00
  static ValueNotifier<String> rideEndDatetime = ValueNotifier(""); // In DATETIME format 1999-12-31 00:00:00

  // Landmark related
  static ValueNotifier<String> landmarkNameMalay = ValueNotifier("");
  static ValueNotifier<String> landmarkNameEnglish = ValueNotifier("");
  static ValueNotifier<String> landmarkType = ValueNotifier("");
  static ValueNotifier<String> landmarkAddress = ValueNotifier("");
  static ValueNotifier<double> landmarkLatitude = ValueNotifier(double.minPositive);
  static ValueNotifier<double> landmarkLongitude = ValueNotifier(double.minPositive);
}