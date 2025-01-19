import 'dart:async';
import 'package:ebikesms/modules/explore/controller/user_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/utils/calculation.dart';
import '../../../shared/utils/shared_state.dart';
import '../../global_import.dart';
import '../controller/bike_controller.dart';
import '../controller/ride_controller.dart';
import '../sub-screen/navigation/screen/nav_destination.dart';
import '../widget/custom_marker.dart';

class RideSessionHandler {

  static Future<void> startSession(BuildContext context, String bikeId) async {
    _updateMarkerCard(MarkerCardContent.loading);
    // Fetch bike data
    var results = await BikeController.getSingleBikeData(bikeId);
    double lat = double.parse(results['data'][0]['current_latitude']);
    double long = double.parse(results['data'][0]['current_longitude']);

    // String? userIdString = await const FlutterSecureStorage().read(key: 'userId');
    // int userId = int.tryParse(userIdString ?? "0") ?? 0;
    int userId = 4; // TODO: Remove hardcoded id

    // Update shared state with bike location
    SharedState.bikeCurrentLatitude.value = lat;
    SharedState.bikeCurrentLongitude.value = long;

    // Assign ride start time
    SharedState.rideStartDatetime.value = await Calculation.getCurrentDateTime();

    // Start ride timer
    SharedState.rideTimer.value = Timer.periodic(const Duration(seconds: 10), (timer) {
      if(SharedState.availableRideTime.value > 0) {
        // Update current ride duration and minus available ride time
        SharedState.currentRideDuration.value = Calculation.convertMinutesToShortRideTime(timer.tick);
        SharedState.availableRideTime.value -= 1;
        updateUserRideTime(userId, SharedState.availableRideTime.value);
      }
      else { // When there is no quota left (availableRideTime)
        SharedState.availableRideTime.value = 0;
        RideSessionHandler.endSession(context);
        return;
      }
    });

    // Update UI and marker states
    SharedState.isRiding.value = true;
    SharedState.cachedMarkers.value = List.from(SharedState.visibleMarkers.value);
    SharedState.visibleMarkers.value = [
      CustomMarker.riding(latitude: lat, longitude: long),
    ];
    _updateMarkerCard(MarkerCardContent.ridingBike);
  }


  static Future<void> endSession(BuildContext context) async {

    // Set the marker card content to loading
    SharedState.markerCardContent.value = MarkerCardContent.loading;

     // Update enableMarkerCard based on the selectedNavIndex
    SharedState.enableMarkerCard.value = (SharedState.selectedNavIndex.value != 0) ? false : true;

    // If selectedNavIndex is 0, call _updateMarkerCard
    if (SharedState.selectedNavIndex.value == 0) {
      _updateMarkerCard(MarkerCardContent.loading);
    }

    // Fetch the end datetime and userId before posting
    SharedState.rideEndDatetime.value = await Calculation.getCurrentDateTime();
    String? userIdString = await const FlutterSecureStorage().read(key: 'userId');
    int userId = int.tryParse(userIdString ?? "0") ?? 0;

    // Post ride session data
    var results = await RideController.postRideSession(
      userId,
      SharedState.bikeId.value,
      SharedState.rideStartDatetime.value,
      SharedState.rideEndDatetime.value,
      Calculation.parseDistance(SharedState.currentTotalDistance.value),
    );
    if (results['status'] == 0) {
      _showSnackbar(context, "Status: ${results['status']}, Message: ${results['message']}");
    }

    // Update bike data
    results = await BikeController.updateSingleBike(
      SharedState.bikeId.value,
      SharedState.bikeStatus.value,
      SharedState.bikeCurrentLatitude.value,
      SharedState.bikeCurrentLongitude.value,
    );
    if (results['status'] == 0) {
      _showSnackbar(context, "Status: ${results['status']}, Message: ${results['message']}");
    }

    // Reset states
    SharedState.enableMarkerCard.value = false;
    SharedState.isRiding.value = false;
    _resetMarkers();
    SharedState.rideTimer.value?.cancel();
    SharedState.rideTimer.value = null;
    SharedState.currentRideDuration.value = "< 1 minute";
    SharedState.currentTotalDistance.value = "< 1 meter";

    // End navigation if ongoing
    if (SharedState.isNavigating.value) {
      endNavigation();
    }
  }


  static void startNavigation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NavDestinationScreen()),
    );
  }


  static void endNavigation() {
    SharedState.isNavigating.value = false;
    SharedState.routePoints.value.clear();
    SharedState.visibleMarkers.value.removeWhere(
          (marker) => marker.key.toString().contains("pinpoint_marker") ||
          marker.key.toString().startsWith("landmark_marker_"),
    );
  }


  // Helper Methods
  static void _updateMarkerCard(MarkerCardContent content) {
    SharedState.enableMarkerCard.value = false;
    SharedState.enableMarkerCard.value = true;
    SharedState.markerCardContent.value = content;
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void _resetMarkers() {
    SharedState.visibleMarkers.value = List.from(SharedState.cachedMarkers.value);
    SharedState.cachedMarkers.value.clear();
  }

  static void updateUserRideTime(int userId, int deductedRideTime) async {
    SharedState.isAvailableRideTimeNewest.value = false;
    await UserController.updateUserRideTime(userId, deductedRideTime);
    SharedState.isAvailableRideTimeNewest.value = true;
  }
}