import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/core/utils.dart';
import 'package:shutter/features/ui/device_screen.dart';
import 'package:shutter/features/ui/screen.dart';
import 'package:shutter/models/parameters_model.dart';

import '../../core/constants/color_constant.dart';
import '../../models/connected_devices.dart';

final connectedDevicesProvider =
    StateProvider<ConnectedDevices?>((ref) => null);

final bleRepositoryProvider = StateNotifierProvider<BleRepository, bool>((ref) {
  return BleRepository(ref: ref);
});
final getConnectedDeviceProvider = StreamProvider((ref) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.getDevicesConnected;
});

final getScannedDeviceProvider = StreamProvider((ref) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.scannedDevices;
});
final connectionStateProvider =
    StreamProvider.family<BluetoothConnectionState, BluetoothDevice>(
        (ref, device) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.getConnectionState(device);
});

class BleRepository extends StateNotifier<bool> {
  final Ref _ref;
  BleRepository({required Ref ref})
      : _ref = ref,
        super(true) {
    _connectedDevicesController
        .add(<ParametersModel>[]); // Emit an initial empty list
  }

  final StreamController<List<BluetoothDevice>> _discoveredDevicesController =
      StreamController<List<BluetoothDevice>>.broadcast();

  Stream<List<BluetoothDevice>> get scannedDevices =>
      _discoveredDevicesController.stream;

  // StreamController for connected devices
  final StreamController<List<ParametersModel>> _connectedDevicesController =
      StreamController<List<ParametersModel>>.broadcast()
        ..add(<ParametersModel>[]);

  final List<BluetoothDevice> discoveredDevices = [];
  final List<ParametersModel> connectedDevices = [];

  Stream<List<ParametersModel>> get getDevicesConnected =>
      _connectedDevicesController.stream.map((devices) {
        if (devices.isEmpty) {
          // Explicitly send an empty list if no devices are connected
          return <ParametersModel>[];
        }
        return devices;
      });

  Stream<BluetoothConnectionState> getConnectionState(
    BluetoothDevice device,
  ) async* {
    // Listen for connection state changes
    await for (final event in device.connectionState) {
      yield event; // Emit the connection state event
    }
  }

  Future<void> deviceScan() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        androidUsesFineLocation: true,
      );

      var subscription = FlutterBluePlus.scanResults.listen(
        (results) {
          discoveredDevices.clear(); // Clear once before adding new devices
          for (ScanResult r in results) {
            if (kDebugMode) {
              print(
                  '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            }
            discoveredDevices.add(r.device);
          }
          _discoveredDevicesController.add(discoveredDevices);
        },
        onError: (e) {
          if (kDebugMode) {
            print('Error during scan: $e');
          }
        },
      );

      // Manage scan subscription lifecycle
      await FlutterBluePlus.isScanning.firstWhere((isScanning) => !isScanning);
      subscription.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('Exception during scan: $e');
      }
      throw e;
    }
  }

  Future<void> deviceConnect(
      {required BluetoothDevice device, required BuildContext context}) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      var services = await device.discoverServices();
      // Debug output
      print("Services discovered: ${services.length}");

      // Process services to find UUIDs
      String readUuid = '';
      String writeUuid = '';
      for (var service in services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          print(c.uuid);
          if (c.properties.notify && readUuid.isEmpty)
            readUuid = c.uuid.toString();
          if (c.properties.writeWithoutResponse && writeUuid.isEmpty)
            writeUuid = c.uuid.toString();
        }
      }

      ParametersModel parametersModel = ParametersModel(
          device: device,
          services: services,
          readUuid: readUuid,
          writeUuid: writeUuid);
      connectedDevices.add(parametersModel);

      // Debug output
      print("Connected Devices Updated: $connectedDevices");

      _connectedDevicesController
          .add(List<ParametersModel>.from(connectedDevices));
      print('writeUuid: $writeUuid');
      print('readUuid: $readUuid');
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => MainScreen(device: device, services: services),
      //   ),
      // );
      //
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceScreen(device: parametersModel),
        ),
      );
      if (connectedDevices.isNotEmpty) {
        _connectedDevicesController
            .add(List<ParametersModel>.from(connectedDevices));
      } else {
        _connectedDevicesController.add(<ParametersModel>[]);
      }
      showSnackBar(context, 'Connected');
    } catch (error) {
      if (kDebugMode) {
        print("Error during connect or discovery: $error");
      }
      showSnackBar(context, 'Connection Failed');
    }
  }

  Future<String> deviceRead(
      {required ParametersModel parametersModel, required String uuid}) async {
    String receivedData = '';
    try {
      for (var service in parametersModel.services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString() == parametersModel.readUuid) {
            if (c.properties.read || c.properties.notify) {
              await c.setNotifyValue(true);
              await for (var value in c.lastValueStream) {
                receivedData = String.fromCharCodes(value);

                if (kDebugMode) {
                  print('Decoded data: $receivedData');
                }

                processReceivedData(receivedString: receivedData);
                break; // Assuming you want to stop listening after the first received data
              }
            } else {
              if (kDebugMode) {
                //   print('READ property not supported by this characteristic');
              }
            }
          } else {
            if (kDebugMode) {
              // print(
              //     'No matching UUID; characteristic was ${c.uuid} and selected UUID was $parametersModel.readUuid');
            }
          }
        }
      }
    } catch (e) {
      print('Error while reading: $e');
    }
    return receivedData;
  }

  void processReceivedData({required String receivedString}) {
    try {
      RegExp shutterRegex = RegExp(r'S:([\d.]+)', caseSensitive: false);
      RegExp autoManualRegex = RegExp(r'E:([\d.]+)', caseSensitive: false);
      RegExp onTimeRegex = RegExp(r'O:([\d.]+)', caseSensitive: false);
      RegExp offTimeRegex = RegExp(r'F:([\d.]+)', caseSensitive: false);
      RegExp aRegex = RegExp(r'A:([\d.]+)', caseSensitive: false);
      RegExp bRegex = RegExp(r'B:([\d.]+)', caseSensitive: false);
      RegExp cRegex = RegExp(r'C:([\d.]+)', caseSensitive: false);

      RegExpMatch? CRegexMatch = cRegex.firstMatch(receivedString);
      double c = CRegexMatch != null
          ? double.tryParse(CRegexMatch.group(1)!) ?? 0.0
          : 0.0;

      RegExpMatch? aRegexMatch = aRegex.firstMatch(receivedString);
      double a = aRegexMatch != null
          ? double.tryParse(aRegexMatch.group(1)!) ?? 0.0
          : 0.0;
      RegExpMatch? bRegexMatch = bRegex.firstMatch(receivedString);
      double b = bRegexMatch != null
          ? double.tryParse(bRegexMatch.group(1)!) ?? 0.0
          : 0.0;
      RegExpMatch? shutterRegexMatch = shutterRegex.firstMatch(receivedString);
      double shutter = shutterRegexMatch != null
          ? double.tryParse(shutterRegexMatch.group(1)!) ?? 0.0
          : 0.0;

      RegExpMatch? autoManualMatch = autoManualRegex.firstMatch(receivedString);
      double autoManual = autoManualMatch != null
          ? double.tryParse(autoManualMatch.group(1)!) ?? 0.0
          : 0.0;
      RegExpMatch? onTimeMatch = onTimeRegex.firstMatch(receivedString);
      double onTime = onTimeMatch != null
          ? double.tryParse(onTimeMatch.group(1)!) ?? 0.0
          : 0.0;
      RegExpMatch? offTimeMatch = offTimeRegex.firstMatch(receivedString);
      double offTime = offTimeMatch != null
          ? double.tryParse(offTimeMatch.group(1)!) ?? 0.0
          : 0.0;

      if (shutter == 0) {
        ColorConstants.sColor = Colors.red;
      } else {
        ColorConstants.sColor = Colors.amber;
      }
      if (a == 0) {
        ColorConstants.aColor = Colors.red;
      } else {
        ColorConstants.aColor = Colors.amber;
      }
      if (b == 0) {
        ColorConstants.bColor = Colors.red;
      } else {
        ColorConstants.bColor = Colors.amber;
      }
      if (c == 0) {
        ColorConstants.cColor = Colors.red;
      } else {
        ColorConstants.cColor = Colors.amber;
      }
    } catch (e) {
      print('Error processing received data: $e');
    }
  }

  Future<void> deviceWrite({
    required BluetoothDevice device,
    required String uuid,
    required String data,
    required List<BluetoothService> services,
  }) async {
    for (var service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString() == uuid) {
          if (c.properties.writeWithoutResponse || c.properties.write) {
            c.setNotifyValue(true);

            c.write(
              data.codeUnits,
              withoutResponse: true,
            );
          } else {
            print('Write property not supported by this characteristic');
          }
        } else {
          print('no matching uuid c was ${c.uuid} and selected uid was ');
        }
      }
    }
  }
}
