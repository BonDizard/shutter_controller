import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:logger/logger.dart';
import '/models/ble_state_model.dart';
import '../core/common/custom_toast.dart';
import '../core/common/show_manual_turn_off_dialog.dart';

final bluetoothProvider =
    StateNotifierProvider<BluetoothNotifier, BluetoothStateModel>(
  (ref) => BluetoothNotifier(ref),
);

class BluetoothNotifier extends StateNotifier<BluetoothStateModel> {
  BluetoothNotifier(this.ref)
      : super(BluetoothStateModel(
          bluetoothEnabled: false,
          isLoading: false,
          connectedDevices: [],
          scanResults: [],
        )) {
    _initBluetooth();
  }
  final Ref ref;
  final Logger logger = Logger();

  void _initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      logger.e('Bluetooth not supported by this device');
      return;
    }

    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      bool isBluetoothEnabled = (state == BluetoothAdapterState.on);
      if (isBluetoothEnabled) {
        startScan();
        fetchConnectedDevices();
      } else {
        stopScan();
      }
      this.state = this.state.copyWith(bluetoothEnabled: isBluetoothEnabled);
    });

    FlutterBluePlus.scanResults.listen((results) {
      this.state = this.state.copyWith(scanResults: results);
    });
  }

  void fetchConnectedDevices() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    state = this.state.copyWith(connectedDevices: devices);
  }

  void toggleBluetooth(BuildContext context, bool value) async {
    try {
      if (value) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        } else if (Platform.isIOS) {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Bluetooth'),
                content: const Text(
                    'iOS does not support programmatically turning on Bluetooth. Please turn it on manually from the settings.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
      } else {
        showManualTurnOffDialog(context);
      }

      if (Platform.isAndroid) {
        state = this.state.copyWith(bluetoothEnabled: value);
      }
    } catch (e) {
      logger.e('Error toggling Bluetooth: $e');
      CustomToast.showToast(
        'Error toggling Bluetooth',
      );
    }
  }

  void startScan() {
    state = this.state.copyWith(isLoading: true);
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4)).then((_) {
      state = this.state.copyWith(isLoading: false);
    }).catchError((e) {
      logger.e('Error starting scan: $e');
      CustomToast.showToast(
        'Error starting scan',
      );
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    state = this.state.copyWith(scanResults: [], isLoading: false);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      for (var connectedDevice in state.connectedDevices) {
        await connectedDevice.disconnect();
      }

      await device.connect();

      state = this.state.copyWith(
            scanResults: state.scanResults
                .where((result) => result.device.remoteId != device.remoteId)
                .toList(),
          );
      fetchConnectedDevices();
    } catch (e) {
      logger.e('Error connecting to device: $e');
      CustomToast.showToast(
        'Error connecting to device',
      );
    }
  }

  void disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      startScan();
      fetchConnectedDevices();
    } catch (e) {
      logger.e('Error disconnecting from device: $e');
      CustomToast.showToast(
        'Error disconnecting from device',
      );
    }
  }
}
