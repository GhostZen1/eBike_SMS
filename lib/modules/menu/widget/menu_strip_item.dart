import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../shared/constants/app_constants.dart';
import '../../../shared/utils/custom_icon.dart';

class StripMenuItem extends StatelessWidget {
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;
  final Color textColor;

  const StripMenuItem({
    super.key,
    this.iconWidget,
    required this.label,
    required this.onTap,
    required this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 20),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstant.lightGrey))
      ),
      child: ListTile(
        leading: iconWidget,
        title: Text(
          label,
          style: TextStyle(
            color: textColor
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}