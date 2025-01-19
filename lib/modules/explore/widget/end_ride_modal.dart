import 'package:ebikesms/modules/explore/controller/bike_controller.dart';
import 'package:ebikesms/modules/explore/controller/ride_controller.dart';
import 'package:ebikesms/modules/global_import.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../shared/utils/calculation.dart';
import '../../../shared/utils/shared_state.dart';
import '../functions/ride_session_handler.dart';

Future<void> EndRideModal(BuildContext context) async {
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
                Navigator.pop(context);
                RideSessionHandler.endSession(context);
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