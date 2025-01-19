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
  static Timer? _currentRideTimer;

  static Future<void> startSession(BuildContext context, String bikeId) async {
    _updateMarkerCard(MarkerCardContent.loading);

    // Fetch bike data
    var results = await BikeController.getSingleBikeData(bikeId);
    double lat = double.parse(results['data'][0]['current_latitude']);
    double long = double.parse(results['data'][0]['current_longitude']);

    // Fetch user data
    String? userIdString = await const FlutterSecureStorage().read(key: 'userId');
    int userId = int.tryParse(userIdString ?? "0") ?? 0;

    // Update shared state with bike location
    SharedState.bikeCurrentLatitude.value = lat;
    SharedState.bikeCurrentLongitude.value = long;

    // Assign ride start time
    SharedState.rideStartDatetime.value = await Calculation.getCurrentDateTime();

    // Start polling current ride duration
    _startRideDurationPolling(context, userId);

    // Start polling current ride distance and rideMarker update
    _startRideDistancePolling(context, bikeId);

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
      Calculation.parseDistance(SharedState.currentRideDistance.value),
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
    _currentRideTimer!.cancel();
    SharedState.currentRideDuration.value = "< 1 minute";
    SharedState.currentRideDistance.value = "< 1 meter";

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
    SharedState.visibleMarkers.value.removeWhere((marker) => marker.key.toString().contains("pinpoint_marker")
          || marker.key.toString().startsWith("landmark_marker_"),
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
    SharedState.visibleMarkers.value.removeWhere((marker) => marker.key == const ValueKey("riding_marker"));
    SharedState.visibleMarkers.value = List.from(SharedState.cachedMarkers.value);
    SharedState.cachedMarkers.value.clear();
  }

  static void _updateUserRideTime(int userId, int deductedRideTime) async {
    SharedState.isAvailableRideTimeNewest.value = false;
    await UserController.updateUserRideTime(userId, deductedRideTime);
    SharedState.isAvailableRideTimeNewest.value = true;
  }

  static void _startRideDurationPolling(BuildContext context, int userId) {
    _currentRideTimer = Timer.periodic(const Duration(seconds: 10), (timer) { // TODO: Rmb to make Duration(minute: 1)
      if(SharedState.availableRideTime.value > 0) {
        // Update current ride duration and minus available ride time
        SharedState.currentRideDuration.value = Calculation.convertMinutesToShortRideTime(timer.tick);
        SharedState.availableRideTime.value -= 1;
        _updateUserRideTime(userId, SharedState.availableRideTime.value);
      }
      else { // When there is no quota left (availableRideTime)
        SharedState.availableRideTime.value = 0;
        RideSessionHandler.endSession(context);
        return;
      }
    });
  }

  static void _startRideDistancePolling(BuildContext context, String bikeId) {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      var results = await BikeController.fetchSingleBike(bikeId);
      if(results['status'] == 0) { // Failed
        _showSnackbar(context, "Status: ${results['status']}, Message: ${results['message']}");
      }
      _updateRideMarkerRealTime(results['data']);
      //SharedState.currentRideDistance.value = results['data']['']; // TODO: Assign total distance here

      // Stop the timer once ride session ends (to conserve ram)
      if(SharedState.isRiding.value == false) {
        SharedState.visibleMarkers.value.removeWhere((marker) => marker.key == const ValueKey("riding_marker"));
        timer.cancel();
      };
    });
  }

  static void _updateRideMarkerRealTime(var bikeData) {
    if (bikeData.isNotEmpty) {
      for (int i = 0; i < bikeData.length; i++) {
        if (bikeData[i]['current_latitude'] != null && bikeData[i]['current_longitude'] != null) {
          double parsedLat = double.parse(bikeData[i]['current_latitude']);
          double parsedLong = double.parse(bikeData[i]['current_longitude']);

          // Remove the old ride marker
          SharedState.visibleMarkers.value.removeWhere((marker) => marker.key == const ValueKey("riding_marker"));

          // Add the new ride marker
          SharedState.visibleMarkers.value.add(
            CustomMarker.riding(
              latitude: parsedLat,
              longitude: parsedLong,
              // onTap: () => _onTapBikeMarker(i),
            ),
          );
        }
      }
    }
  }
}