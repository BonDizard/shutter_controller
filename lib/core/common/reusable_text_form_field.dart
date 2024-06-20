import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final IconData iconData;
  final Color fillColor;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.iconData,
    this.fillColor = const Color(0xFFE0E0E0), // Default light grey color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
          labelText: labelText,
          prefixIcon: Icon(iconData),
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        ),
      ),
    );
  }
}
