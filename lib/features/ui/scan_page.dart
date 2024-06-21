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
        title: const Text('spec-rule'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ref.read(bleRepositoryProvider.notifier).deviceScan,
                child: const Text('Scan for Devices'),
              ),
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
                            loading: () =>
                                const Center(child: Text('scan devices')),
                          ),
                    ),
              const Divider(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(BluetoothDevice device) {
    // Watch the connection state provider for the specific device
    final connectionStatus = ref.watch(connectionStateProvider(device));

    return Card(
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
                          return const ListTile(
                            leading: Icon(Icons.error),
                          );
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          if (kDebugMode) {
                            print('No RSSI data available');
                          }
                          return const ListTile(
                            leading: Icon(Icons.error),
                          );
                        } else {
                          final rssi = snapshot.data ??
                              -100; // Default to a weak signal if null
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
    );
  }

// Function to determine range icon based on RSSI
  Widget getRangeIcon(int rssi) {
    if (rssi > -60) {
      return const Icon(
          Icons.signal_cellular_alt_rounded); // Very close (strong signal)
    } else if (rssi > -70) {
      return const Icon(
          Icons.signal_cellular_alt_2_bar_sharp); // Close (good signal)
    } else if (rssi > -80) {
      return const Icon(
          Icons.signal_cellular_alt_1_bar); // Medium (moderate signal)
    } else {
      return const Icon(Icons
          .signal_cellular_connected_no_internet_0_bar); // Far (weak signal)
    }
  }
}
