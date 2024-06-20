import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:shutter/core/common/reusable_swtch.dart';

import '../../core/common/connectio_status_bar.dart';
import '../../core/common/reusable_button.dart';
import '../../core/common/reusable_text_form_field.dart';
import '../../core/constants/communication_constant.dart';
import '../../models/parameters_model.dart';
import '../repository/ble_repository.dart';

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

  bool autoManual = false;
  String receivedData = '';

  BluetoothConnectionState deviceState = BluetoothConnectionState.disconnected;
  StreamSubscription<BluetoothConnectionState>? _stateListener;

  @override
  void dispose() {
    // Release the state listener
    _stateListener?.cancel();
    // Disconnect

    if (kDebugMode) {
      print('Disposing MainScreen');
    }
    onTimeController.dispose();
    offTimeController.dispose();
    super.dispose();
  }

  Future<void> readDataFromDevice(BluetoothDevice device, String uuid) async {
    var data = await ref
        .watch(bleRepositoryProvider.notifier)
        .deviceRead(parametersModel: widget.device, uuid: uuid);
    if (mounted) {
      setState(() {
        receivedData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    readDataFromDevice(widget.device.device, widget.device.readUuid);
    print('build write: ${widget.device.writeUuid}');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.device.platformName),
        actions: [
          ConnectionStatusIndicator(
            device: widget.device.device,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              receivedData,
              style: TextStyle(color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ReusableButton(
                    onButtonClick: () {
                      ref.read(bleRepositoryProvider.notifier).deviceWrite(
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
                      ref.read(bleRepositoryProvider.notifier).deviceWrite(
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
                      ref.read(bleRepositoryProvider.notifier).deviceWrite(
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
                      ref.read(bleRepositoryProvider.notifier).deviceWrite(
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
            SizedBox(
              height: 30,
            ),
            FlutterToggleTab(
              width: 70,
              borderRadius: 15,
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              unSelectedTextStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              labels: ['Auto', 'Manual'],
              selectedIndex: autoManual ? 1 : 0,
              selectedLabelIndex: (index) {
                setState(() {
                  autoManual = index != 0;
                });
                ref.read(bleRepositoryProvider.notifier).deviceWrite(
                      services: widget.device.services,
                      uuid: widget.device.readUuid,
                      device: widget.device.device,
                      data: CommunicationConstant.autoManualToggleKey,
                    );
              },
            ),
            SizedBox(
              height: 30,
            ),
            CustomTextField(
              controller: onTimeController,
              hintText: 'Enter on time',
              labelText: 'On Time',
              iconData: Icons.timer,
            ),
            CustomTextField(
              controller: offTimeController,
              hintText: 'Enter off time',
              labelText: 'Off Time',
              iconData: Icons.timer_off,
            ),
            TextButton(
              onPressed: () {
                print('Sending data to BLE: ${onTimeController.text}');
                if (offTimeController.text.trim().isNotEmpty) {}
                ref.read(bleRepositoryProvider.notifier).deviceWrite(
                      services: widget.device.services!,
                      uuid: widget.device.readUuid,
                      device: widget.device.device,
                      data: CommunicationConstant.onTimeKey +
                          onTimeController.text +
                          CommunicationConstant.autoManualToggleKey,
                    );
                ref.read(bleRepositoryProvider.notifier).deviceWrite(
                      services: widget.device.services,
                      uuid: widget.device.readUuid,
                      device: widget.device.device,
                      data: CommunicationConstant.offTimeKey +
                          offTimeController.text +
                          CommunicationConstant.autoManualToggleKey,
                    );
              },
              child: Icon(
                Icons.send,
                size: 50,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text('on time'),
            StepperSlider(
              initialValue: double.parse(onTimeController.text.trim().isEmpty
                  ? "0"
                  : onTimeController.text.trim()),
              minValue: 0,
              maxValue: 2000,
              onChanged: (double value) {
                print('onTimeSliderValue: $value');
                setState(() {
                  onTimeController.text = value.toString();
                });
                ref.read(bleRepositoryProvider.notifier).deviceWrite(
                      services: widget.device.services,
                      uuid: widget.device.readUuid,
                      device: widget.device.device,
                      data: value.toString() +
                          CommunicationConstant.onTimeKey +
                          'e',
                    );
              },
            ),
            SizedBox(
              height: 30,
            ),
            Text('off time'),
            StepperSlider(
              initialValue: double.parse(offTimeController.text.trim().isEmpty
                  ? "0"
                  : offTimeController.text.trim()),
              minValue: 0,
              maxValue: 2000,
              onChanged: (double value) {
                print('onTimeSliderValue: $value');
                setState(() {
                  offTimeController.text = value.toString();
                });
                ref.read(bleRepositoryProvider.notifier).deviceWrite(
                      services: widget.device.services,
                      uuid: widget.device.readUuid,
                      device: widget.device.device,
                      data: value.toString() +
                          CommunicationConstant.onTimeKey +
                          'e',
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
