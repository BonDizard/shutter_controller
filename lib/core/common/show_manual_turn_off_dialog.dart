import 'package:flutter/material.dart';

void showManualTurnOffDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Turn off Bluetooth'),
        content:
            const Text('Please turn off Bluetooth manually from the settings.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
