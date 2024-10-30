import 'package:flutter/material.dart';

class CameraCountDownWidget extends StatelessWidget {
  const CameraCountDownWidget({
    super.key,
    required this.isPhoneSteady,
    required this.countdown,
  });

  final bool isPhoneSteady;
  final int countdown;

  @override
  Widget build(BuildContext context) {
    return Text(
      isPhoneSteady ? '$countdown' : 'Hold the Device Steady',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 25,
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.none),
    );
  }
}
