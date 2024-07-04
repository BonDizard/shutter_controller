import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/ble_constants.dart';
import '../constants/color_constant.dart';

class ReusableIconButton extends StatefulWidget {
  const ReusableIconButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  State<ReusableIconButton> createState() => _ReusableIconButtonState();
}

class _ReusableIconButtonState extends State<ReusableIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          BLEConstants.lightIsOn = !BLEConstants.lightIsOn;
          BLEConstants.lightIsOn = !BLEConstants.lightIsOn;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF747D8C).withOpacity(0.5),
              blurRadius: 50,
            ),
          ],
          color: ColorConstants.darkColor,
          gradient: LinearGradient(
            colors: BLEConstants.lightIsOn
                ? [ColorConstants.surface, ColorConstants.surface]
                : [
                    ColorConstants.backgroundColorOne,
                    ColorConstants.backgroundColorTwo,
                  ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: BLEConstants.lightIsOn
                      ? [
                          ColorConstants.onColorOne,
                          ColorConstants.onColorTwo,
                          ColorConstants.onColorThree,
                        ]
                      : [
                          ColorConstants.backgroundColorOne,
                          ColorConstants.backgroundColorTwo,
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(100))),
            child: IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                BLEConstants.lightIsOn
                    ? CupertinoIcons.lightbulb
                    : CupertinoIcons.lightbulb_slash,
                color: BLEConstants.lightIsOn
                    ? ColorConstants.surface
                    : ColorConstants.darkColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
