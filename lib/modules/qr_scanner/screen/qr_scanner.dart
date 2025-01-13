import 'package:ebikesms/modules/global_import.dart';
import 'package:ebikesms/shared/utils/shared_state.dart';
import 'package:ebikesms/shared/widget/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:camera/camera.dart';

import '../../../shared/constants/app_constants.dart';
import '../../../shared/utils/custom_icon.dart';
import '../../explore/controller/bike_controller.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  QRCodeDartScanController? _controller;
  CameraController? _cameraController;
  bool _isFlashlightOn = false;
  bool _isCameraCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = QRCodeDartScanController();
    _initializeCamera();  // Initialize the camera for flashlight control
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose of the camera controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    // Dimensions of the QR code hole
    final holeSize = MediaQuery.of(context).size.width * 0.55;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // QR Code Scanner View (background)
          QRCodeDartScanView(
            controller: _controller,
            resolutionPreset: QRCodeDartScanResolutionPreset.medium,
            onCapture: (result) => _askConfirmation(result)
          ),

          // Grey area layer
          ColorFiltered(
            colorFilter: ColorFilter.mode(ColorConstant.black.withOpacity(0.8), BlendMode.srcOut), // This one will create the magic
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: ColorConstant.black,
                    backgroundBlendMode: BlendMode.dstOut
                  ), // This one will handle background + difference out
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: holeSize,
                    width: holeSize,
                    decoration: BoxDecoration(
                      color: ColorConstant.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hole border, overlapping grey area layer
          (!_isCameraCompleted)
              ? Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: ColorConstant.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: ColorConstant.shadow, // Shadow color
                        offset: Offset(0, 2),                 // Shadow position
                        blurRadius: 10.0,                      // Spread of the shadow
                        spreadRadius: 0.0                     // Additional spread
                    )
                  ]
                ),
                child: const LoadingAnimation(dimension: 40))
              )
              : Align(
              alignment: Alignment.center,
              child: Container(
                width: holeSize,
                height: holeSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),

          // Close button, overlapping grey area layer
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Add padding for safe area
            left: 10,
            child: IconButton(
                onPressed: () { Navigator.pop(context); },
                icon: CustomIcon.close(20, color: ColorConstant.white)
            ),
          ),

          //UI elements: Flashlight button, instructions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Instructions
              const Text(
                'Scan the QR code\nlocated on the bike handle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: holeSize,
                height: holeSize
              ),
              const SizedBox(height: 50),

              // Flashlight (torch) button
              IconButton(
                icon: Icon(
                  _isFlashlightOn ? Icons.flashlight_off : Icons.flashlight_on,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _toggleFlashlight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to check if the scanned QR code matches the bike ID pattern
  bool _isValidBikeId(String id) {
    // Regex to match a bike ID that starts with 'B125' followed by 2 random digits
    final regex = RegExp(r'^B25\d{3}$');
    return regex.hasMatch(id) &&  id.isNotEmpty;
  }

  // Method to show an error dialog if the bike ID is invalid
  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Invalid QR code. Please scan a valid bike ID.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Initialize camera for flashlight control
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {
      _isCameraCompleted = true;
    });
  }

  // Toggle flashlight on/off
  void _toggleFlashlight() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      if (_isFlashlightOn) {
        await _cameraController!.setFlashMode(FlashMode.off); // Turn off flashlight
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch); // Turn on flashlight
      }
      setState(() {
        _isFlashlightOn = !_isFlashlightOn;  // Update flashlight state
      });
    }
  }

  void _askConfirmation(result) async {
    if(!_isValidBikeId(result.text)) {
      _showErrorDialog(context);
      return;
    }

    // Change the screen
    SharedState.selectedNavIndex.value = 0;

    // Set loading content while waiting to fetch bike data
    SharedState.markerCardVisibility.value = false; // Purposely make it false first in order to see change
    SharedState.markerCardVisibility.value = true;
    SharedState.markerCardContent.value = MarkerCardContent.loading;

    // Fetch bike data
    String bikeId = result.text;
    var results = await BikeController.getSingleBikeData(bikeId);
    if (results['status'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status: ${results['status']}, Message: ${results['message']}")),
      );
      return;
    }

    // Set loading content while waiting to fetch bike data
    SharedState.markerCardVisibility.value = false; // Purposely make it false first in order to see change
    SharedState.markerCardVisibility.value = true;
    SharedState.markerCardContent.value = MarkerCardContent.confirmBike;
    SharedState.bikeId.value = results['data'][0]['bike_id'];
    SharedState.bikeStatus.value = results['data'][0]['status'];
    Navigator.pop(context);
  }
}