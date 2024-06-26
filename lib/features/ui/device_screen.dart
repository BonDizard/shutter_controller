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
    logger.d('writeUuid: ${updatedDevice.writeUuid}');

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
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
            // Text(
            //   receivedData,
            //   style: Theme.of(context).textTheme.bodyLarge,
            // ),
            SizedBox(
              height: 20,
            ),
            Row(
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
                      data: CommunicationConstant.relayOneToggleKey,
                    );
                  },
                  visibleText: '1',
                ),
                ReusableButton(
                  onButtonClick: () {
                    bluetoothNotifier.writeToDevice(
                      services: updatedDevice.services,
                      uuid: updatedDevice.writeUuid,
                      device: updatedDevice.device,
                      data: CommunicationConstant.relayTwoToggleKey,
                    );
                  },
                  visibleText: '2',
                ),
                ReusableButton(
                  onButtonClick: () {
                    bluetoothNotifier.writeToDevice(
                      services: updatedDevice.services,
                      uuid: updatedDevice.writeUuid,
                      device: updatedDevice.device,
                      data: CommunicationConstant.relayThreeToggleKey,
                    );
                  },
                  visibleText: '3',
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
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

            SizedBox(
              height: height * 0.5,
              child: Column(
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: height * 0.02,
                        right: height * 0.02,
                        top: height * 0.02,
                        bottom: height * 0.04,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kTertiary
                              : kTertiaryLight,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Center(
                              child: Text(
                                'On Time',
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomTextField(
                                    device: updatedDevice,
                                    controller: onTimeController,
                                    hintText: 'Enter on time',
                                    labelText: 'On Time',
                                    iconData: Icons.timer,
                                  ),
                                  Text(
                                    BLEConstants.onTimeReceivedFromBleDevice
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print(
                                            'Sending data to BLE: ${onTimeController.text}');
                                      }
                                      if (onTimeController.text
                                          .trim()
                                          .isEmpty) {
                                        logger.i('on Time Empty');
                                        CustomToast.showToast(
                                          'on Time Empty',
                                        );
                                      } else {
                                        bluetoothNotifier.writeToDevice(
                                          services: updatedDevice.services,
                                          uuid: updatedDevice.writeUuid,
                                          device: updatedDevice.device,
                                          data:
                                              CommunicationConstant.onTimeKey +
                                                  onTimeController.text +
                                                  CommunicationConstant
                                                      .autoManualToggleKey,
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.send,
                                      size: width * 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ReusableSlider(
                                initialValue: onTimeSliderValue,
                                onChanged: (double value) {
                                  if (kDebugMode) {
                                    print('onTimeSliderValue: $value');
                                  }
                                  setState(() {
                                    onTimeSliderValue = value;
                                    onTimeController.text =
                                        onTimeSliderValue.toInt().toString();
                                  });
                                  bluetoothNotifier.writeToDevice(
                                    services: updatedDevice.services,
                                    uuid: updatedDevice.writeUuid,
                                    device: updatedDevice.device,
                                    data: value.toString() +
                                        CommunicationConstant.onTimeKey +
                                        CommunicationConstant
                                            .autoManualToggleKey,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: height * 0.02,
                        right: height * 0.02,
                        top: height * 0.02,
                        bottom: height * 0.04,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? kTertiary
                              : kTertiaryLight,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: height * 0.01,
                            ),
                            Center(
                              child: Text(
                                'Off Time',
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomTextField(
                                    device: updatedDevice,
                                    controller: offTimeController,
                                    hintText: 'Enter off time',
                                    labelText: 'Off Time',
                                    iconData: Icons.timer,
                                  ),
                                  Text(
                                    BLEConstants.offTimeReceivedFromBleDevice
                                        .toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print(
                                            'Sending data to BLE: ${offTimeController.text}');
                                      }
                                      if (offTimeController.text
                                          .trim()
                                          .isEmpty) {
                                        logger.i('off Time Empty');
                                        CustomToast.showToast(
                                          'off Time Empty',
                                        );
                                      } else {
                                        bluetoothNotifier.writeToDevice(
                                          services: updatedDevice.services,
                                          uuid: updatedDevice.writeUuid,
                                          device: updatedDevice.device,
                                          data:
                                              CommunicationConstant.offTimeKey +
                                                  offTimeController.text +
                                                  CommunicationConstant
                                                      .autoManualToggleKey,
                                        );
                                      }
                                    },
                                    child: Icon(
                                      Icons.send,
                                      size: width * 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ReusableSlider(
                                initialValue: offTimeSliderValue,
                                onChanged: (double value) {
                                  if (kDebugMode) {
                                    print('onTimeSliderValue: $value');
                                  }
                                  setState(() {
                                    offTimeSliderValue = value;
                                    offTimeController.text =
                                        offTimeSliderValue.toInt().toString();
                                  });
                                  bluetoothNotifier.writeToDevice(
                                    services: updatedDevice.services,
                                    uuid: updatedDevice.writeUuid,
                                    device: updatedDevice.device,
                                    data: value.toString() +
                                        CommunicationConstant.offTimeKey +
                                        CommunicationConstant
                                            .autoManualToggleKey,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
