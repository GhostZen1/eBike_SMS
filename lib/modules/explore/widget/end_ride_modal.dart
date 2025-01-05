import 'package:ebikesms/modules/global_import.dart';
import '../../../shared/utils/calculation.dart';
import '../../../shared/utils/shared_state.dart';

Future<void> EndRideModal(BuildContext context, MapController mapController) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // User must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        alignment: Alignment.center,
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Center(
                    child: Text(
                      'Are you sure of ending the ride session?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
                  )))
            ],
          ),
        ),
        actions: <Widget>[
          Container(
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: ColorConstant.lightGrey))),
            child: ListTile(
              title: const Center(
                  child: Text(
                "End ride",
                style: TextStyle(color: ColorConstant.red),
              )),
              onTap: () {
                _endRide(context);
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: ColorConstant.lightGrey))),
            child: ListTile(
              title: const Center(child: Text("Resume")),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}

void _endRide(BuildContext context) async {
  // Set marker card to loading
  Navigator.pop(context);
  SharedState.markerCardContent.value = MarkerCardContent.loading;

  // Prepare posting of data
  SharedState.rideEndDatetime.value = await Calculation.getCurrentDateTime();
  SharedState.currentRideTime.value;
  // TODO: Post ride (start and end datetime) and bike (new current latlong) data to the database

  // After data is posted, reset map and marker card UI
  SharedState.isRiding.value = false;
  SharedState.visibleMarkers.value.clear();
  SharedState.visibleMarkers.value.addAll(SharedState.cachedMarkers.value);
  SharedState.timer.value?.cancel();
  SharedState.currentRideTime.value = "< 1 minute";
  SharedState.currentTotalDistance.value = "< 1 meter";
  // Must set to false first, then true again to make sure ValueListenableBuilder of MarkerCard listens
  SharedState.markerCardVisibility.value = false;
  SharedState.markerCardVisibility.value = true;
  // This is not redundant code. (Though it can be improved)

  // End navigation if it's ongoing
  if (SharedState.isNavigating.value) {
    SharedState.isNavigating.value = false;
    SharedState.routePoints.value = [];
    SharedState.visibleMarkers.value = SharedState.visibleMarkers.value
      .where((marker) {
        // Check if the marker key does not start with "landmark_marker"
        return !(marker.key.toString().startsWith("landmark_marker"));
      })
      .toList();
  }
}
