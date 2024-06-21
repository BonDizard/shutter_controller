import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
      child: SfSlider(
        min: 0,
        max: 2000,
        value: _sliderValue,
        interval: 2000 / 10,
        showTicks: true,
        showLabels: true,
        enableTooltip: true,
        minorTicksPerInterval: 1,
        onChanged: (dynamic value) {
          setState(() {
            _sliderValue = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
      ),
    );
  }
}
