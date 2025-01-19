import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_constants.dart';

class LoadingAnimation extends StatefulWidget {
  final double dimension;
  final bool enableBackground;
  const LoadingAnimation({
    super.key,
    required this.dimension,
    this.enableBackground = false
  });

  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Full rotation in 1 second
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    final rotatingIcon = RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        'assets/icons/loading-coloured.svg',
        width: widget.dimension,
        height: widget.dimension,
      ),
    );

    return (!widget.enableBackground)
        ? rotatingIcon
        : Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
                color: ColorConstant.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: ColorConstant.shadow,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                      spreadRadius: 0
                  )
                ]
              ),
              child: rotatingIcon
            )
          );
  }
}
