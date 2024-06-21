import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/repository/ble_repository.dart';
import '../../models/parameters_model.dart';
import '../constants/communication_constant.dart';

class CustomTextField extends ConsumerWidget {
  final ParametersModel device;
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final IconData iconData;
  final Color fillColor;

  const CustomTextField({
    required this.device,
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.iconData,
    this.fillColor = const Color(0xFFE0E0E0), // Default light grey color
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: screenWidth / 3, // Set the width to half the screen width
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
            labelText: labelText,
            prefixIcon: Icon(iconData),
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          ),
          onSubmitted: (String value) {
            if (kDebugMode) {
              print('User typed: $value');
            }
            ref.read(bleRepositoryProvider.notifier).writeToDevice(
                  services: device.services,
                  uuid: device.readUuid,
                  device: device.device,
                  data: CommunicationConstant.onTimeKey +
                      controller.text +
                      CommunicationConstant.autoManualToggleKey,
                );
          },
        ),
      ),
    );
  }
}
