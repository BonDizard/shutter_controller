import 'package:flutter/material.dart';
import 'package:stepper_counter_swipe/stepper_counter_swipe.dart';

class StepperSlider extends StatefulWidget {
  final double initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<double>? onChanged;

  const StepperSlider({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  StepperSliderState createState() => StepperSliderState();
}

class StepperSliderState extends State<StepperSlider> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        child: StepperSwipe(
          initialValue: widget.initialValue.toInt(),
          speedTransitionLimitCount: 3,
          firstIncrementDuration: const Duration(milliseconds: 300),
          secondIncrementDuration: const Duration(milliseconds: 100),
          direction: Axis.horizontal,
          dragButtonColor: Theme.of(context).colorScheme.primary,
          iconsColor: Theme.of(context).colorScheme.error,
          withSpring: true,
          withBackground: false,
          maxValue: widget.maxValue,
          minValue: widget.minValue,
          withFastCount: true,
          counterTextColor: Colors.white,
          stepperValue: _sliderValue.toInt(),
          onChanged: (int val) {
            setState(() {
              _sliderValue = val.toDouble();
            });
            widget.onChanged!(_sliderValue);
          },
        ),
      ),
    );
  }
}
