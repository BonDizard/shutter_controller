import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:logger/logger.dart';
import 'package:shutter/core/common/reusable_slider.dart';
import 'package:shutter/core/constants/ble_constants.dart';
import 'package:shutter/core/constants/constants.dart';

import '../../core/common/connectio_status_bar.dart';
import '../../core/common/custom_toast.dart';
import '../../core/common/drawer.dart';
import '../../core/common/reusable_button.dart';
import '../../core/common/reusable_text_form_field.dart';
import '../../core/constants/communication_constant.dart';
import '../../models/parameters_model.dart';
import '../repository/bluetooth_provider.dart';
import '../repository/parameters_provider.dart';

class DeviceScreen extends ConsumerStatefulWidget {
  final ParametersModel device;
  final int index;

  const DeviceScreen({
    super.key,
    required this.device,
    required this.index,
  });

  @override
  ConsumerState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  TextEditingController onTimeController = TextEditingController();
  TextEditingController offTimeController = TextEditingController();

  final Logger logger = Logger();

  String receivedData = '';

  double onTimeSliderValue = 0;
  double offTimeSliderValue = 0;

  @override
  void dispose() {
    if (kDebugMode) {
      print('Disposing MainScreen');
    }
    onTimeController.dispose();
    offTimeController.dispose();
    super.dispose();
  }

  Future<void> readDataFromDevice(BluetoothDevice device, String? uuid) async {
    if (uuid == null) return;
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    var data = await bluetoothNotifier.readTheDataFromDevice(
        parametersModel: widget.device, uuid: uuid, context: context);
    if (mounted) {
      setState(() {
        receivedData = data;
      });
    }
  }

  void _updateUuids(String? readUuid, String? writeUuid) {
    ref
        .read(parametersModelProvider.notifier)
        .updateUuids(widget.index, readUuid, writeUuid);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    final updatedDevice = ref.watch(parametersModelProvider)[widget.index];
    logger.d('readUuid: ${updatedDevice.readUuid}');
    logger.d('writeuuid: ${updatedDevice.writeUuid}');

    readDataFromDevice(updatedDevice.device, updatedDevice.readUuid);
    return Scaffold(
      drawer: CustomDrawer(
        parametersModel: updatedDevice,
        onUpdateUuids: _updateUuids,
        index: widget.index,
      ),
      appBar: AppBar(
        title: Text('Device: ${updatedDevice.device.platformName}'),
        actions: [
          ConnectionStatusIndicator(
            device: updatedDevice.device,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(width * 0.045),
              ),
              height: height * 0.14,
              child: Padding(
                padding: EdgeInsets.all(width * 0.03),
                child: Image.asset(
                  'assets/images/app_logo/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Text(
          //   receivedData,
          //   style: Theme.of(context).textTheme.bodyLarge,
          // ),
          Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ReusableButton(
                  onButtonClick: () {
                    bluetoothNotifier.writeToDevice(
                      services: updatedDevice.services,
                      uuid: updatedDevice.writeUuid,
                      device: updatedDevice.device,
                      data: CommunicationConstant.shutterOnOffToggleKey +
                          CommunicationConstant.autoManualToggleKey,
                    );
                  },
                  visibleText: 'S',
                ),
                ReusableButton(
                  onButtonClick: () {
                    bluetoothNotifier.writeToDevice(
                      services: updatedDevice.services,
                      uuid: updatedDevice.writeUuid,
                      device: updatedDevice.device,
                      data: CommunicationConstant.relayAToggleKey +
                          CommunicationConstant.autoManualToggleKey,
                    );
                  },
                  visibleText: 'A',
                ),
                ReusableButton(
                  onButtonClick: () {
                    bluetoothNotifier.writeToDevice(
                      services: updatedDevice.services,
                      uuid: updatedDevice.writeUuid,
                      device: updatedDevice.device,
                      data: CommunicationConstant.relayBToggleKey +
                          CommunicationConstant.autoManualToggleKey,
                    );
                  },
                  visibleText: 'B',
                ),
                ReusableButton(
                  onButtonClick: () {
                    bluetoothNotifier.writeToDevice(
                      services: updatedDevice.services,
                      uuid: updatedDevice.writeUuid,
                      device: updatedDevice.device,
                      data: CommunicationConstant.relayCToggleKey +
                          CommunicationConstant.autoManualToggleKey,
                    );
                  },
                  visibleText: 'C',
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.03),
          FlutterToggleTab(
            width: width * 0.17,
            borderRadius: width * 0.03,
            selectedBackgroundColors: [
              Theme.of(context).brightness == Brightness.dark
                  ? kTertiary
                  : kTertiaryLight
            ],
            unSelectedBackgroundColors: [
              Theme.of(context).brightness == Brightness.dark
                  ? kSecondary
                  : kSecondaryLight
            ],
            selectedTextStyle: Theme.of(context).textTheme.headlineLarge,
            unSelectedTextStyle: Theme.of(context).textTheme.bodyLarge,
            labels: const ['Auto', 'Manual'],
            selectedIndex: BLEConstants.autoManualToggleKey ? 1 : 0,
            selectedLabelIndex: (index) {
              setState(() {
                BLEConstants.autoManualToggleKey = index != 0;
              });
              bluetoothNotifier.writeToDevice(
                services: updatedDevice.services,
                uuid: updatedDevice.writeUuid,
                device: updatedDevice.device,
                data: CommunicationConstant.autoManualToggleKey,
              );
            },
          ),
          SizedBox(height: width * 0.03),
          Card(
            elevation: 4.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? kTertiary
                : kTertiaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'On Time',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomTextField(
                        device: updatedDevice,
                        controller: onTimeController,
                        hintText: 'Enter on time',
                        labelText: 'On Time',
                        iconData: Icons.timer,
                      ),
                      Column(
                        children: [
                          Text(
                            BLEConstants.onTimeReceivedFromBleDevice.toString(),
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          // Text(
                          //   'Received Value',
                          //   style: Theme.of(context).textTheme.bodyLarge,
                          // ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          if (kDebugMode) {
                            print(
                                'Sending data to BLE: ${onTimeController.text}');
                          }
                          if (onTimeController.text.trim().isEmpty) {
                            logger.i('on Time Empty');
                            CustomToast.showToast(
                              'on Time Empty',
                            );
                          } else {
                            bluetoothNotifier.writeToDevice(
                              services: updatedDevice.services,
                              uuid: updatedDevice.writeUuid,
                              device: updatedDevice.device,
                              data: CommunicationConstant.onTimeKey +
                                  onTimeController.text +
                                  CommunicationConstant.autoManualToggleKey,
                            );
                          }
                        },
                        child: const Icon(
                          Icons.send,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: width * 0.03),
                  ReusableSlider(
                    initialValue: onTimeSliderValue,
                    onChanged: (double value) {
                      if (kDebugMode) {
                        print('onTimeSliderValue: $value');
                      }
                      setState(() {
                        onTimeSliderValue = value;
                        onTimeController.text = onTimeSliderValue.toString();
                      });
                      bluetoothNotifier.writeToDevice(
                        services: updatedDevice.services,
                        uuid: updatedDevice.writeUuid,
                        device: updatedDevice.device,
                        data: value.toString() +
                            CommunicationConstant.onTimeKey +
                            CommunicationConstant.autoManualToggleKey,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Card(
            elevation: 4.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? kTertiary
                : kTertiaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Off Time',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomTextField(
                        device: updatedDevice,
                        controller: offTimeController,
                        hintText: 'Enter off time',
                        labelText: 'Off Time',
                        iconData: Icons.timer,
                      ),
                      Column(
                        children: [
                          Text(
                            BLEConstants.offTimeReceivedFromBleDevice
                                .toString(),
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          // Text(
                          //   'Received Value',
                          //   style: Theme.of(context).textTheme.bodyLarge,
                          // ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          if (kDebugMode) {
                            print(
                                'Sending data to BLE: ${offTimeController.text}');
                          }
                          if (offTimeController.text.trim().isEmpty) {
                            logger.i('Off Time Empty');
                            CustomToast.showToast(
                              'Off Time Empty',
                            );
                          } else {
                            bluetoothNotifier.writeToDevice(
                              services: updatedDevice.services,
                              uuid: updatedDevice.writeUuid,
                              device: updatedDevice.device,
                              data: CommunicationConstant.offTimeKey +
                                  offTimeController.text +
                                  CommunicationConstant.autoManualToggleKey,
                            );
                          }
                        },
                        child: const Icon(
                          Icons.send,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ReusableSlider(
                    initialValue: offTimeSliderValue,
                    onChanged: (double value) {
                      if (kDebugMode) {
                        print('offTimeSliderValue: $value');
                      }
                      setState(() {
                        offTimeSliderValue = value;
                        offTimeController.text = offTimeSliderValue.toString();
                      });
                      bluetoothNotifier.writeToDevice(
                        services: updatedDevice.services,
                        uuid: updatedDevice.writeUuid,
                        device: updatedDevice.device,
                        data: value.toString() +
                            CommunicationConstant.offTimeKey +
                            CommunicationConstant.autoManualToggleKey,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
