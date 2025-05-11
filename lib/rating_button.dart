import 'package:flutter/cupertino.dart';
import 'dart:ui';

class RatingButton extends StatelessWidget {
  final int value;
  final VoidCallback onPressed;

  const RatingButton({
    Key? key,
    required this.value,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: CupertinoColors.white,
      minSize: 64,
      onPressed: onPressed,
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            color: CupertinoColors.black,
            fontFeatures: [FontFeature.tabularFigures()],
            fontFamily: 'JetBrainsMono',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
