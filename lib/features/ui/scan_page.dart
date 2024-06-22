import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/common/loading.dart';
import '../repository/ble_repository.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  void onTappingTheDeviceConnectToIt(
      {required BluetoothDevice selectedDevice}) async {
    ref
        .watch(bleRepositoryProvider.notifier)
        .connectToDevice(selectedDevice: selectedDevice, context: context);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(bleRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPEC - RULE'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    isLoading
                        ? const Loader()
                        : Expanded(
                            child: ref.watch(getScannedDeviceProvider).when(
                                  data: (devices) => ListView.builder(
                                    itemCount: devices.length,
                                    itemBuilder: (context, index) =>
                                        buildListTile(devices[index]),
                                  ),
                                  error: (error, stackTrace) =>
                                      Center(child: Text(error.toString())),
                                  loading: () => const Center(
                                    child: Text('press scan for devices'),
                                  ),
                                ),
                          ),
                    const Divider(color: Colors.white),
                    const SizedBox(
                        height: 8), // Add space between divider and button
                    ElevatedButton(
                      onPressed:
                          ref.read(bleRepositoryProvider.notifier).deviceScan,
                      child: const Text('Scan for Devices'),
                    ),
                    const SizedBox(
                        height: 8), // Add space between button and divider
                    const Divider(color: Colors.white),
                  ],
                ),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'Connected Devices',
                      style: TextStyle(color: Colors.red),
                    ),
                    Expanded(
                        child: Center(
                      child: Text('connected devices'),
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(BluetoothDevice device) {
    final connectionStatus = ref.watch(connectionStateProvider(device));

    return Card(
      elevation: 3,
      shadowColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withAlpha(60),
              blurRadius: 6.0,
              spreadRadius: 0.0,
              offset: const Offset(
                0.0,
                3.0,
              ),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            device.platformName.isEmpty ? 'N/A' : device.platformName,
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: Text(device.remoteId.toString()),
          trailing: connectionStatus.when(
            data: (isConnected) =>
                isConnected == BluetoothConnectionState.connected
                    ? const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.bluetooth_disabled,
                        color: Colors.red,
                      ),
            error: (error, stackTrace) => const SizedBox(),
            loading: () => const CircularProgressIndicator(),
          ),
          leading: connectionStatus.when(
            data: (isConnected) =>
                isConnected == BluetoothConnectionState.connected
                    ? FutureBuilder<int>(
                        future: device.readRssi(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            if (kDebugMode) {
                              print('No RSSI data available');
                            }
                            return const Icon(Icons.error);
                          } else {
                            final rssi = snapshot.data ?? -100;
                            return getRangeIcon(rssi);
                          }
                        },
                      )
                    : const SizedBox(),
            error: (error, stackTrace) => const SizedBox(),
            loading: () => const CircularProgressIndicator(),
          ),
          onTap: () => onTappingTheDeviceConnectToIt(selectedDevice: device),
        ),
      ),
    );
  }

  Widget buildConnectedDeviceTile(BluetoothDevice device) {
    return Card(
      elevation: 3,
      shadowColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(
            device.platformName.isEmpty ? 'N/A' : device.platformName,
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: Text(device.remoteId.toString()),
          trailing: const Icon(Icons.bluetooth_connected, color: Colors.green),
          leading: const Icon(Icons.bluetooth, color: Colors.blue),
          onTap: () => onTappingTheDeviceConnectToIt(selectedDevice: device),
        ),
      ),
    );
  }

  Widget getRangeIcon(int rssi) {
    if (rssi > -60) {
      return const Icon(Icons.signal_cellular_alt_rounded);
    } else if (rssi > -70) {
      return const Icon(Icons.signal_cellular_alt_2_bar_sharp);
    } else if (rssi > -80) {
      return const Icon(Icons.signal_cellular_alt_1_bar);
    } else {
      return const Icon(Icons.signal_cellular_connected_no_internet_0_bar);
    }
  }
}
