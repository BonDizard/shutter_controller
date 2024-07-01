import 'package:flutter/material.dart';
import 'package:shutter/core/constants/ble_constants.dart';

import '../constants/color_constant.dart';

class ReusableCommunicationButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool mirror;

  const ReusableCommunicationButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.mirror = true,
  });

  @override
  ReusableCommunicationButtonState createState() =>
      ReusableCommunicationButtonState();
}

class ReusableCommunicationButtonState
    extends State<ReusableCommunicationButton> {
  bool isOn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void findIfItIsOn() {
    switch (widget.buttonText) {
      case 'S':
        isOn = BLEConstants.sIsOn;
        break;
      case '1':
        isOn = BLEConstants.oneIsOn;
        break;
      case '2':
        isOn = BLEConstants.twoIsOn;
        break;
      case '3':
        isOn = BLEConstants.threeIsOn;
        break;
      default:
        isOn = false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    findIfItIsOn();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        setState(() {
          isOn = !isOn;
        });
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: height * 0.07, // Define the height here
        width: width * 0.35, // Define the width here
        decoration: isOn
            ? BoxDecoration(
                border: const Border(
                  left: BorderSide(color: Colors.white),
                  top: BorderSide(color: Colors.white),
                  right: BorderSide(color: Colors.white),
                  bottom: BorderSide(color: Colors.white),
                ),
                color: ColorConstants.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 14.4,
                    offset: const Offset(-7.2, -7.2),
                  ),
                  const BoxShadow(
                    color: ColorConstants.backgroundColorTwo,
                    blurRadius: 14.4,
                    offset: Offset(7.2, 7.2),
                  ),
                ],
                borderRadius: widget.mirror
                    ? const BorderRadius.only(
                        bottomRight: Radius.circular(35),
                        bottomLeft: Radius.circular(17),
                        topRight: Radius.circular(17),
                        topLeft: Radius.circular(35),
                      )
                    : const BorderRadius.only(
                        bottomRight: Radius.circular(17),
                        bottomLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                        topLeft: Radius.circular(17),
                      ),
              )
            : BoxDecoration(
                color: ColorConstants.surface,
                gradient: const LinearGradient(
                  colors: [
                    ColorConstants.backgroundColorOne,
                    ColorConstants.backgroundColorTwo,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF747D8C).withOpacity(0.5),
                    blurRadius: 50,
                  ),
                ],
                borderRadius: widget.mirror
                    ? const BorderRadius.only(
                        bottomRight: Radius.circular(35),
                        bottomLeft: Radius.circular(17),
                        topRight: Radius.circular(17),
                        topLeft: Radius.circular(35),
                      )
                    : const BorderRadius.only(
                        bottomRight: Radius.circular(17),
                        bottomLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                        topLeft: Radius.circular(17),
                      ),
              ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: isOn
                ? BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ColorConstants.onColorOne,
                        ColorConstants.onColorTwo,
                        ColorConstants.onColorThree,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: widget.mirror
                        ? const BorderRadius.only(
                            bottomRight: Radius.circular(35),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                            topLeft: Radius.circular(35),
                          )
                        : const BorderRadius.only(
                            bottomRight: Radius.circular(17),
                            bottomLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                            topLeft: Radius.circular(17),
                          ),
                  )
                : BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ColorConstants.backgroundColorOne,
                        ColorConstants.backgroundColorTwo,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: widget.mirror
                        ? const BorderRadius.only(
                            bottomRight: Radius.circular(35),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                            topLeft: Radius.circular(35),
                          )
                        : const BorderRadius.only(
                            bottomRight: Radius.circular(17),
                            bottomLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                            topLeft: Radius.circular(17),
                          ),
                  ),
            child: Center(
              child: Text(
                widget.buttonText,
                style: TextStyle(
                  fontFamily: 'Alatsi',
                  color:
                      isOn ? ColorConstants.surface : ColorConstants.darkColor,
                  fontSize: width * 0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
