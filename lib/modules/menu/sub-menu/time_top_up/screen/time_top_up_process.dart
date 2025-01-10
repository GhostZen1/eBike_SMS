import 'package:flutter/material.dart';
import 'package:ebikesms/modules/menu/screen/menu.dart';
import 'package:ebikesms/shared/constants/app_constants.dart';
import 'package:ebikesms/modules/menu/sub-menu/time_top_up/controller/transaction_controller.dart';
import 'package:ebikesms/shared/utils/custom_icon.dart';
import 'package:ebikesms/shared/utils/calculation.dart';
import 'package:ebikesms/shared/widget/loading_animation.dart';
import '../../../../../shared/widget/custom_buttons.dart';

class TimeTopUpProcessScreen extends StatefulWidget {
  final int userId;
  final int keyedTotal;
  const TimeTopUpProcessScreen(
      {super.key, required this.userId, required this.keyedTotal});

  @override
  State<TimeTopUpProcessScreen> createState() => _TimeTopUpProcessScreenState();
}

class _TimeTopUpProcessScreenState extends State<TimeTopUpProcessScreen> {
  late String transactionDate;
  late int transactionTotal;
  late int obtainedRideTime;
  late int userId;

  bool isSuccessful = false;

  @override
  void initState() {
    super.initState();
    _startValidation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, userId);
            },
            icon: CustomIcon.close(20, color: ColorConstant.black)),
        title: const Text("Processing Payment"),
        centerTitle: true,
      ),
      body: isSuccessful ? _displaySuccessfulView() : _displayLoadingView(),
    );
  }

  Widget _displayLoadingView() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LoadingAnimation(dimension: 100),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
          child: Text(
            "Processing...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IntrinsicWidth(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            "Please do not exit this page while it's processing. It may take a few seconds",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ))
      ],
    );
  }

  Widget _displaySuccessfulView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomIcon.checkedColoured(100),
                const Padding(
                  padding: EdgeInsets.fromLTRB(50, 40, 50, 10),
                  child: Text(
                    "Payment was\nSuccessful",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
            child: CustomRectangleButton(
              label: "Back to menu",
              onPressed: () {
                Navigator.pop(context, userId);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startValidation() async {
    await _initDetails();
    await _processTransaction();
  }

  Future<void> _initDetails() async {
    String dateTime = await Calculation.getCurrentDateTime();
    setState(() {
      transactionDate = dateTime;
      transactionTotal = widget.keyedTotal;
      obtainedRideTime = Calculation.convertMoneyToMinutes(transactionTotal);
      userId = widget.userId; // Get from login
    });
  }

  Future<void> _processTransaction() async {
    var result = await TransactionController.addTransaction(
      transactionDate: transactionDate,
      transactionTotal: transactionTotal,
      obtainedRideTime: obtainedRideTime,
      userId: userId,
    );

    // Error occurred, display a snack bar
    if (result['status'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
          duration: const Duration(seconds: 2)));
      setState(() {
        isSuccessful = false;
      });
    }
    // Successful
    else if (result['status'] == 1) {
      // For fake loading effect :P
      await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
      setState(() {
        isSuccessful = true;
      });
    }
  }
}
