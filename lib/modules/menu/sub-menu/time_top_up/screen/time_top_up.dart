import 'package:ebikesms/modules/menu/sub-menu/time_top_up/screen/time_top_up_process.dart';
import 'package:ebikesms/shared/utils/calculation.dart';
import 'package:ebikesms/shared/utils/custom_icon.dart';
import 'package:ebikesms/shared/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/widget/custom_buttons.dart';

class TimeTopUpScreen extends StatefulWidget {
  final int userId;
  const TimeTopUpScreen({super.key, required this.userId});

  @override
  _TimeTopUpScreenState createState() => _TimeTopUpScreenState();
}

class _TimeTopUpScreenState extends State<TimeTopUpScreen> {
  final TextEditingController _controller = TextEditingController();
  late int userId;
  bool isValidAmount = false;
  String labelText = "";
  Color labelColor = ColorConstant.black;

  int rideTimeAvailable = 0; // KIV
  int rideTimeVacantValue =
      PricingConstant.rideTimeLimit - 0; // rideTimeAvailable;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final amount = int.tryParse(_controller.text) ?? 0;
      final rideTopUpLimit = rideTimeVacantValue * PricingConstant.priceRate;

      setState(() {
        if (amount < PricingConstant.minTopUpAmt) {
          // Displays minimum amount
          labelText = "Minimum amount: ${TextConstant.minTopUpLabel}";
          labelColor = ColorConstant.black;
          isValidAmount = false;
        } else if (amount > rideTopUpLimit) {
          // Displays ride time will be topped up (if appropriate amount)
          labelText = "Max is 30 hours. Your limit: RM$rideTopUpLimit";
          labelColor = ColorConstant.red;
          isValidAmount = false;
        } else {
          // If amount is over the limit
          labelText =
              "Ride Time: ${Calculation.convertMoneyToLongRideTime(int.parse(_controller.text))}";
          labelColor = ColorConstant.black;
          isValidAmount = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: CustomIcon.close(20, color: ColorConstant.black)),
        title: const Text("Enter amount"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: IntrinsicWidth(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      cursorColor: ColorConstant.darkBlue,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _LeadingZeroInputFormatter(),
                      ],
                      controller: _controller,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        prefixText: 'RM',
                        prefixStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                        hintText: '0',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Text(labelText, style: TextStyle(color: labelColor))
              ],
            ),
          ),
          Column(
            children: [
              const Text(
                "Rate: ${TextConstant.priceRateLabel}",
                style: TextStyle(fontSize: 14),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(40, 10, 40, 30),
                child: CustomRectangleButton(
                  label: "Confirm",
                  onPressed: () {
                    int value = int.parse(_controller.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimeTopUpProcessScreen(
                          userId: widget.userId,
                          keyedTotal: value,
                        ),
                      ),
                    ).then((_) {
                      setState(() {
                        labelText = "New label text after returning";
                        labelColor = ColorConstant.black;
                      });
                    });
                  },
                  enable: isValidAmount ? true : false,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// This InputFormatter disallows multiple leading zeros
class _LeadingZeroInputFormatter extends TextInputFormatter {
  @override
  // TextEditingValue executes when the field is being edited everytime
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final currentValue = newValue.text;
    if (currentValue.startsWith('0') && currentValue.length > 1) {
      return oldValue;
    }
    if (currentValue.length > 3) {
      return oldValue;
    }
    return newValue;
  }
}
