import 'package:flutter/material.dart';
import 'package:simple_animated_button/elevated_layer_button.dart';

class ReusableButton extends StatelessWidget {
  final String visibleText;
  final VoidCallback onButtonClick;
  final double width;

  const ReusableButton({
    super.key,
    required this.visibleText,
    required this.onButtonClick,
    this.width = 70,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedLayerButton(
      onClick: onButtonClick,
      buttonHeight: 70,
      buttonWidth: width,
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.ease,
      topDecoration: BoxDecoration(
        color: Colors.amber,
        border: Border.all(),
      ),
      topLayerChild: Text(
        visibleText,
        style: TextStyle(fontSize: 20),
      ),
      baseDecoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(),
      ),
    );
  }
}
