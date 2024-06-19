import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/core/utils.dart';
import 'package:shutter/models/parameters_model.dart';
import '../../core/constants/constants.dart';
import '../../models/connected_devices.dart';

final connectedDevicesProvider =
    StateProvider<ConnectedDevices?>((ref) => null);

final bleRepositoryProvider = StateNotifierProvider<BleRepository, bool>((ref) {
  return BleRepository(ref: ref);
});
final getConnectedDeviceProvider = StreamProvider((ref) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.getConnectedDevice();
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
final readDataFromBLEProvider =
    StreamProvider.family<String, BluetoothDevice>((ref, device) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.read(device: device);
});

class BleRepository extends StateNotifier<bool> {
  final Ref _ref;
  BleRepository({required Ref ref})
      : _ref = ref,
        super(true);

  final StreamController<List<BluetoothDevice>> _discoveredDevicesController =
      StreamController<List<BluetoothDevice>>.broadcast();
  Stream<List<BluetoothDevice>> get scannedDevices =>
      _discoveredDevicesController.stream;

  final List<BluetoothDevice> discoveredDevices = [];
  final List<BluetoothDevice> connectedDevices = [];

  // void getConnectedDevice() {
  //   final List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
  //   connectedDevices.clear();
  //   for (var dev in devs) {
  //     final de = ParametersModel(
  //       shutterOnOffToggleValue: false,
  //       autoManualToggleKey: false,
  //       onTimeKey: 0.0,
  //       offTimeKey: 0.0,
  //       device: dev,
  //     );
  //     connectedDevices.add(de);
  //   }
  //   final connectedDevs = ConnectedDevices(connectedDevices: connectedDevices);
  //   _ref
  //       .read(connectedDevicesProvider.notifier)
  //       .update((state) => connectedDevs);
  // }
  Stream<List<BluetoothDevice>> getConnectedDevice() async* {
    final List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    connectedDevices.clear();
    connectedDevices.addAll(devs);
    yield connectedDevices;
  }

  List<BluetoothDevice> getDevicesConnected() {
    List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    print('inside the ble');
    for (var d in devs) {
      print('devices: $d');
    }
    print('done');
    return devs;
  }

  Stream<BluetoothConnectionState> getConnectionState(
    BluetoothDevice device,
  ) async* {
    // Listen for connection state changes
    await for (final event in device.connectionState) {
      yield event; // Emit the connection state event
    }
  }

  Future<void> scan() async {
    try {
      // Start scanning with specified parameters
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        androidUsesFineLocation: true,
      );

      print('Scan started.');
      print('Starting Bluetooth scan...');

      // Listen for scan results
      var subscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (ScanResult r in results) {
            if (kDebugMode) {
              print(
                  '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
            }
            discoveredDevices.clear();
            discoveredDevices.addAll(results.map((r) => r.device).toList());
            // Emit the updated list of discovered devices
            _discoveredDevicesController.add(discoveredDevices);
          }
        },
        onError: (e) {
          if (kDebugMode) {
            print('Error during scan: $e');
          }
        },
      );

      print('Subscribed to scan results.');

      // Cancel the scan subscription when scan completes
      FlutterBluePlus.cancelWhenScanComplete(subscription);

      print('Waiting for Bluetooth adapter to be on...');

      // Wait for Bluetooth adapter to be on
      await FlutterBluePlus.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .first;

      print('Bluetooth adapter is on.');

      // Wait until scanning completes (isScanning becomes false)
      await FlutterBluePlus.isScanning.where((isScanning) => !isScanning).first;
      print('discoveredDevices: $discoveredDevices');
      print('Scan completed.');
    } catch (e) {
      // Handle any exceptions that occur during scanning
      if (kDebugMode) {
        print('Exception during scan: $e');
      }
      // Optionally re-throw the exception for higher level handling
      throw e;
    }
  }

  Future<void> connect(
      {required BluetoothDevice device, required BuildContext context}) async {
    var subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
        // Remove the device from discoveredDevices upon successful connection
        discoveredDevices.remove(device);
        _discoveredDevicesController.add(discoveredDevices);
        print('Connected to device: ${device.name}');
      } else if (state == BluetoothConnectionState.disconnected) {
        if (kDebugMode) {
          print("disconnected");
        }
      }
    });

    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

    await device.connect();
    showSnackBar(context, 'connected');
  }

  Stream<String> read({required BluetoothDevice device}) async* {
    print('inside read');
    final service = await device.discoverServices();
    for (BluetoothService s in service) {
      for (BluetoothCharacteristic c in s.characteristics) {
        await for (final value in c.lastValueStream) {
          print('value: ${value.toString()}');
          yield String.fromCharCodes(value);
        }
      }
    }
  }

  void processReceivedData({required String receivedString}) {
    try {
      RegExp shutterRegex = RegExp(r's:([\d.]+)', caseSensitive: false);
      RegExp autoManualRegex = RegExp(r'e:([\d.]+)', caseSensitive: false);
      RegExp onTimeRegex = RegExp(r'o:([\d.]+)', caseSensitive: false);
      RegExp offTimeRegex = RegExp(r'f:([\d.]+)', caseSensitive: false);

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
    } catch (e) {
      print('Error processing received data: $e');
    }
  }

  Future<void> write({
    required BluetoothDevice device,
    required String uuid,
    required String data,
    required List<BluetoothService> services,
  }) async {
    for (var service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.uuid.toString() == uuid) {
          if (c.properties.writeWithoutResponse) {
            c.setNotifyValue(true);
            print('the data sending: $data');
            c.write(
              data.codeUnits,
              withoutResponse: true,
            );
            print('***********************');
          } else {
            //   print('Write property not supported by this characteristic');
          }
        } else {
          // print('no matching uuid c was ${c.uuid} and selected uid was ');
        }
      }
    }
  }
}
