import 'package:flutter/material.dart';
import 'package:shutter/core/constants/constants.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ReusableSlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double>? onChanged;

  const ReusableSlider({
    super.key,
    required this.initialValue,
    this.onChanged,
  });

  @override
  ReusableSliderState createState() => ReusableSliderState();
}

class ReusableSliderState extends State<ReusableSlider> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SfSliderTheme(
        data: SfSliderThemeData(
          activeLabelStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? kPrimary
                : kPrimaryLight,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          inactiveLabelStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? kSecondary
                  : kSecondaryLight,
              fontSize: 12,
              fontStyle: FontStyle.italic),
        ),
        child: SfSlider(
          min: 0,
          max: 2000,
          value: _sliderValue,
          interval: 2000 / 10,
          showTicks: true,
          inactiveColor: Theme.of(context).brightness == Brightness.dark
              ? kSecondary
              : kSecondaryLight,
          showLabels: true,
          enableTooltip: true,
          minorTicksPerInterval: 1,
          activeColor: Colors.white,
          onChanged: (dynamic value) {
            setState(() {
              _sliderValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
        ),
      ),
    );
  }
}
