import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/core/constants/constants.dart';
import '../../features/repository/bluetooth_provider.dart';
import '../../models/parameters_model.dart';
import '../constants/communication_constant.dart';

class CustomTextField extends ConsumerWidget {
  final ParametersModel device;
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final IconData iconData;

  const CustomTextField({
    required this.device,
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.iconData,
    // Default light grey color
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
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
            labelStyle: Theme.of(context).textTheme.bodyLarge,
            hintStyle: Theme.of(context).textTheme.bodyLarge,
            prefixIcon: Icon(
              iconData,
              color: Theme.of(context).brightness == Brightness.dark
                  ? kPrimaryLight
                  : kPrimary,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? kSecondary
                : kSecondaryLight,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          ),
          onSubmitted: (String value) {
            if (kDebugMode) {
              print('User typed: $value');
            }
            bluetoothNotifier.writeToDevice(
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
