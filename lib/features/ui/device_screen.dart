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

class DeviceScreen extends ConsumerStatefulWidget {
  final ParametersModel device;
  const DeviceScreen({
    super.key,
    required this.device,
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

  Future<void> readDataFromDevice(BluetoothDevice device, String uuid) async {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    var data = await bluetoothNotifier.readTheDataFromDevice(
        parametersModel: widget.device, uuid: uuid, context: context);
    if (mounted) {
      setState(() {
        receivedData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);

    readDataFromDevice(widget.device.device, widget.device.readUuid);
    // if (kDebugMode) {
    //   print('build read: ${widget.device.readUuid}');
    //   print('build write: ${widget.device.writeUuid}');
    // }
    return Scaffold(
      drawer: CustomDrawer(
        parametersModel: widget.device,
      ),
      appBar: AppBar(
        title: Text('Device: ${widget.device.device.platformName}'),
        actions: [
          ConnectionStatusIndicator(
            device: widget.device.device,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/app_logo/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Text(
              receivedData,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ReusableButton(
                    onButtonClick: () {
                      bluetoothNotifier.writeToDevice(
                        services: widget.device.services,
                        uuid: widget.device.writeUuid,
                        device: widget.device.device,
                        data: CommunicationConstant.shutterOnOffToggleKey +
                            CommunicationConstant.autoManualToggleKey,
                      );
                    },
                    visibleText: 'S',
                  ),
                  ReusableButton(
                    onButtonClick: () {
                      bluetoothNotifier.writeToDevice(
                        services: widget.device.services,
                        uuid: widget.device.writeUuid,
                        device: widget.device.device,
                        data: CommunicationConstant.relayAToggleKey +
                            CommunicationConstant.autoManualToggleKey,
                      );
                    },
                    visibleText: 'A',
                  ),
                  ReusableButton(
                    onButtonClick: () {
                      bluetoothNotifier.writeToDevice(
                        services: widget.device.services,
                        uuid: widget.device.writeUuid,
                        device: widget.device.device,
                        data: CommunicationConstant.relayBToggleKey +
                            CommunicationConstant.autoManualToggleKey,
                      );
                    },
                    visibleText: 'B',
                  ),
                  ReusableButton(
                    onButtonClick: () {
                      bluetoothNotifier.writeToDevice(
                        services: widget.device.services,
                        uuid: widget.device.writeUuid,
                        device: widget.device.device,
                        data: CommunicationConstant.relayCToggleKey +
                            CommunicationConstant.autoManualToggleKey,
                      );
                    },
                    visibleText: 'C',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            FlutterToggleTab(
              width: 70,
              borderRadius: 15,
              selectedBackgroundColors: [kTertiary],
              unSelectedBackgroundColors: [kSecondary],
              selectedTextStyle: Theme.of(context).textTheme.headlineLarge,
              unSelectedTextStyle: Theme.of(context).textTheme.bodyLarge,
              labels: const ['Auto', 'Manual'],
              selectedIndex: BLEConstants.autoManualToggleKey ? 1 : 0,
              selectedLabelIndex: (index) {
                setState(() {
                  BLEConstants.autoManualToggleKey = index != 0;
                });
                bluetoothNotifier.writeToDevice(
                  services: widget.device.services,
                  uuid: widget.device.readUuid,
                  device: widget.device.device,
                  data: CommunicationConstant.autoManualToggleKey,
                );
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Card(
              elevation: 4.0,
              color: kTertiary,
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
                          device: widget.device,
                          controller: onTimeController,
                          hintText: 'Enter on time',
                          labelText: 'On Time',
                          iconData: Icons.timer,
                        ),
                        Column(
                          children: [
                            Text(
                              BLEConstants.onTimeReceivedFromBleDevice
                                  .toString(),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Text(
                              'Received Value',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
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
                            }
                            bluetoothNotifier.writeToDevice(
                              services: widget.device.services,
                              uuid: widget.device.readUuid,
                              device: widget.device.device,
                              data: CommunicationConstant.onTimeKey +
                                  onTimeController.text +
                                  CommunicationConstant.autoManualToggleKey,
                            );
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
                          services: widget.device.services,
                          uuid: widget.device.readUuid,
                          device: widget.device.device,
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
            const SizedBox(
              height: 15,
            ),
            Card(
              elevation: 4.0,
              color: kTertiary,
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
                          device: widget.device,
                          controller: offTimeController,
                          hintText: 'Enter on time',
                          labelText: 'Off Time',
                          iconData: Icons.timer,
                        ),
                        Column(
                          children: [
                            Text(
                              BLEConstants.onTimeReceivedFromBleDevice
                                  .toString(),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Text(
                              'Received Value',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            if (kDebugMode) {
                              print(
                                  'Sending data to BLE: ${offTimeController.text}');
                            }
                            if (offTimeController.text.trim().isEmpty) {
                              logger.i('off Time Empty');
                              CustomToast.showToast(
                                'off Time Empty',
                              );
                            }
                            bluetoothNotifier.writeToDevice(
                              services: widget.device.services,
                              uuid: widget.device.writeUuid,
                              device: widget.device.device,
                              data: CommunicationConstant.onTimeKey +
                                  offTimeController.text +
                                  CommunicationConstant.autoManualToggleKey,
                            );
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
                          print('onTimeSliderValue: $value');
                        }
                        setState(() {
                          offTimeSliderValue = value;
                          offTimeController.text =
                              offTimeSliderValue.toString();
                        });
                        bluetoothNotifier.writeToDevice(
                          services: widget.device.services,
                          uuid: widget.device.readUuid,
                          device: widget.device.device,
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
      ),
    );
  }
}
