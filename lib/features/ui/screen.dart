import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:shutter/core/constants/communication_constant.dart';

import '../../core/common/reusable_button.dart';
import '../repository/ble_repository.dart';

class MainScreen extends ConsumerStatefulWidget {
  final BluetoothDevice device;
  final List<BluetoothService>? services;
  const MainScreen({required this.device, required this.services, Key? key})
      : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  TextEditingController onTimeController = TextEditingController();
  TextEditingController offTimeController = TextEditingController();
  bool shutter = false;
  bool autoManual = false;
  String receivedData = '';
  String? selectedUuid;
  List<Map<String, String>> uuidsWithProperties = [];
  late Timer timer;
  static String stateText = 'Connecting';
  String connectButtonText = 'Disconnect';
  BluetoothConnectionState deviceState = BluetoothConnectionState.disconnected;
  StreamSubscription<BluetoothConnectionState>? _stateListener;

  @override
  void initState() {
    super.initState();
    _initializeUuids(); // Register the state connection listener
    _stateListener = widget.device.connectionState.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // Ignore if the state is the same
        return;
      }
      // Update the connection state information
      setBleConnectionState(event);
    });
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        readDataFromDevice(widget.device, selectedUuid!);
      });
    });
  }

  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      widget.device.disconnect();
    } catch (e) {}
  }

  @override
  void dispose() {
    // Release the state listener
    _stateListener?.cancel();
    // Disconnect
    disconnect();
    if (kDebugMode) {
      print('Disposing MainScreen');
    }
    onTimeController.dispose();
    offTimeController.dispose();
    super.dispose();
  }

  void _initializeUuids() {
    for (var service in widget.services!) {
      for (BluetoothCharacteristic c in service.characteristics) {
        String properties = '';
        if (c.properties.read) properties += 'Read ';
        if (c.properties.write) properties += 'Write ';
        if (c.properties.notify) properties += 'Notify ';
        if (c.properties.writeWithoutResponse) properties += 'WriteWR ';
        if (c.properties.indicate) properties += 'Indicate ';
        uuidsWithProperties
            .add({'uuid': c.uuid.toString(), 'properties': properties.trim()});
      }
    }
    if (uuidsWithProperties.isNotEmpty) {
      selectedUuid = uuidsWithProperties.first['uuid'];
      readDataFromDevice(widget.device, selectedUuid!);
    }
  }

  Future<void> readDataFromDevice(BluetoothDevice device, String uuid) async {
    try {
      for (var service in widget.services!) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString() == selectedUuid) {
            if (c.properties.read || c.properties.notify) {
              // List<int> value = await c.read();
              c.setNotifyValue(true);
              c.lastValueStream.listen((value) {
                receivedData = String.fromCharCodes(value);
              });

              setState(() {});
              if (kDebugMode) {
                print('Decoded data: $receivedData');
              }
            } else {
              // print('READ property not supported by this characteristic');
            }
          } else {
            // print('no matching uuid c was ${c.uuid} and selected uid was $selectedUuid');
          }
        }
      }
    } catch (e) {
      print('Error while reading: $e');
    }
  }

  /* Update the connection state */
  setBleConnectionState(BluetoothConnectionState event) {
    switch (event) {
      case BluetoothConnectionState.disconnected:
        stateText = 'Disconnected';
        // Change button state
        connectButtonText = 'Connect';
        break;
      case BluetoothConnectionState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothConnectionState.connected:
        stateText = 'Connected';
        // Change button state
        connectButtonText = 'Disconnect';
        break;
      case BluetoothConnectionState.connecting:
        stateText = 'Connecting';
        break;
    }
    // Save the previous state event
    deviceState = event;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    readDataFromDevice(widget.device, selectedUuid!);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              stateText,
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
            Text(
              receivedData,
              style: TextStyle(color: Colors.black),
            ),
            DropdownButton<String>(
              value: selectedUuid,
              items: uuidsWithProperties.map((Map<String, String> uuidData) {
                return DropdownMenuItem<String>(
                  value: uuidData['uuid'],
                  child:
                      Text('${uuidData['uuid']} (${uuidData['properties']})'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedUuid = newValue;
                  readDataFromDevice(widget.device, selectedUuid!);
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ReusableButton(
                  onButtonClick: () {
                    ref.read(bleRepositoryProvider.notifier).writeToDevice(
                          services: widget.services!,
                          uuid: selectedUuid!,
                          device: widget.device,
                          data: CommunicationConstant.shutterOnOffToggleKey +
                              CommunicationConstant.autoManualToggleKey,
                        );
                  },
                  visibleText: 'S',
                ),
                ReusableButton(
                  onButtonClick: () {
                    ref.read(bleRepositoryProvider.notifier).writeToDevice(
                          services: widget.services!,
                          uuid: selectedUuid!,
                          device: widget.device,
                          data: CommunicationConstant.relayAToggleKey +
                              CommunicationConstant.autoManualToggleKey,
                        );
                  },
                  visibleText: 'A',
                ),
                ReusableButton(
                  onButtonClick: () {
                    ref.read(bleRepositoryProvider.notifier).writeToDevice(
                          services: widget.services!,
                          uuid: selectedUuid!,
                          device: widget.device,
                          data: CommunicationConstant.relayBToggleKey +
                              CommunicationConstant.autoManualToggleKey,
                        );
                  },
                  visibleText: 'B',
                ),
                ReusableButton(
                  onButtonClick: () {
                    ref.read(bleRepositoryProvider.notifier).writeToDevice(
                          services: widget.services!,
                          uuid: selectedUuid!,
                          device: widget.device,
                          data: CommunicationConstant.relayCToggleKey +
                              CommunicationConstant.autoManualToggleKey,
                        );
                  },
                  visibleText: 'C',
                ),
              ],
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
                ref.read(bleRepositoryProvider.notifier).writeToDevice(
                      services: widget.services!,
                      uuid: selectedUuid!,
                      device: widget.device,
                      data: CommunicationConstant.autoManualToggleKey,
                    );
              },
            ),
            TextField(
              controller: onTimeController,
              decoration: InputDecoration(
                hintText: 'on time',
                label: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text('on time'),
                ),
              ),
            ),
            TextField(
              controller: offTimeController,
              decoration: InputDecoration(
                hintText: 'off time',
                label: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text('off time'),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                print('Sending data to BLE: ${onTimeController.text}');
                if (offTimeController.text.trim().isNotEmpty) {}
                ref.read(bleRepositoryProvider.notifier).writeToDevice(
                      services: widget.services!,
                      uuid: selectedUuid!,
                      device: widget.device,
                      data: CommunicationConstant.onTimeKey +
                          onTimeController.text +
                          CommunicationConstant.autoManualToggleKey,
                    );
                ref.read(bleRepositoryProvider.notifier).writeToDevice(
                      services: widget.services!,
                      uuid: selectedUuid!,
                      device: widget.device,
                      data: CommunicationConstant.offTimeKey +
                          offTimeController.text +
                          CommunicationConstant.autoManualToggleKey,
                    );
              },
              child: Text('Send'),
            ),
            Text('on time'),
            Slider(
              min: 10,
              max: 2000,
              value: onTimeController.text.isEmpty
                  ? 10.0
                  : double.parse(onTimeController.text),
              onChanged: (double value) {
                print('onTimeSliderValue: $value');
                setState(() {
                  onTimeController.text = value.toString();
                });
                ref.read(bleRepositoryProvider.notifier).writeToDevice(
                      services: widget.services!,
                      uuid: selectedUuid!,
                      device: widget.device,
                      data: value.toString() +
                          CommunicationConstant.onTimeKey +
                          'e',
                    );
              },
            ),
            Text('off time'),
            Slider(
              min: 10,
              max: 2000,
              value: offTimeController.text.isEmpty
                  ? 10.0
                  : double.parse(offTimeController.text),
              onChanged: (double value) {
                print('offTimeSliderValue: $value');
                setState(() {
                  offTimeController.text = value.toString();
                });
                ref.read(bleRepositoryProvider.notifier).writeToDevice(
                      services: widget.services!,
                      uuid: selectedUuid!,
                      device: widget.device,
                      data: value.toString() +
                          CommunicationConstant.offTimeKey +
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
