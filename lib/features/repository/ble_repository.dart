import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/core/utils.dart';

import '../../core/constants/constatnts.dart';

final bleRepositoryProvider = StateNotifierProvider<BleRepository, bool>((ref) {
  return BleRepository();
});

final getScannedDeviceProvider = StreamProvider((ref) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.scannedDevices;
});

final getConnectedDeviceProvider = StreamProvider((ref) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.getConnectedDevice();
});

final readDataFromBLEProvider =
    StreamProvider.family<String, BluetoothDevice>((ref, device) {
  final bleRepository = ref.watch(bleRepositoryProvider.notifier);
  return bleRepository.read(device: device);
});

class BleRepository extends StateNotifier<bool> {
  BleRepository() : super(true);
  // Stream controller for discovered devices
  final StreamController<List<BluetoothDevice>> _discoveredDevicesController =
      StreamController<List<BluetoothDevice>>.broadcast();
  Stream<List<BluetoothDevice>> get scannedDevices =>
      _discoveredDevicesController.stream;

  final List<BluetoothDevice> discoveredDevices = [];
  final List<BluetoothDevice> connectedDevices = [];

  Stream<List<BluetoothDevice>> getConnectedDevice() async* {
    final List<BluetoothDevice> devs = FlutterBluePlus.connectedDevices;
    connectedDevices.clear();
    connectedDevices.addAll(devs);
    yield connectedDevices;
  }

  Future<void> scan() async {
    try {
      // Start scanning with specified parameters
      await FlutterBluePlus.startScan(
        withServices: [Guid(BLEConstants.serviceUuidConstant)],
        timeout: const Duration(seconds: 15),
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
    final service = await device.discoverServices();
    for (BluetoothService s in service) {
      if (s.uuid.toString() == BLEConstants.serviceUuidConstant) {
        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid.toString() == BLEConstants.characteristicConstant &&
              c.properties.read) {
            await c.setNotifyValue(true);
            await for (final value in c.lastValueStream) {
              yield String.fromCharCodes(value);
            }
          }
        }
      }
    }
  }

  Future<void> write(
      {required BluetoothDevice device, required String data}) async {
    final service = await device.discoverServices();
    for (BluetoothService s in service) {
      if (s.uuid.toString() == BLEConstants.serviceUuidConstant) {
        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid.toString() == BLEConstants.characteristicConstant &&
              c.properties.write) {
            await c.write(data.codeUnits);
          }
        }
      }
    }
  }
}
