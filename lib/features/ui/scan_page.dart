import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/features/ui/screen.dart';
import '../repository/ble_repository.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  List<BluetoothService> bluetoothService = [];

  void onTap(BluetoothDevice device) async {
    await device.connect(
      timeout: const Duration(seconds: 10),
    );

    try {
      List<BluetoothService> services = [];
      if (kDebugMode) {
        print('bluetoothService.isEmpty: ${bluetoothService.isEmpty}');
      }
      services = await device.discoverServices(timeout: 10);
      setState(() {
        bluetoothService = services;
      });

      // Navigate to the amplitude page with the device and services
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            services: bluetoothService,
            device: device,
          ),
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error connecting to device or discovering services: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ref.read(bleRepositoryProvider.notifier).scan,
                child: const Text('Scan for Devices'),
              ),
              Expanded(
                child: ref.watch(getScannedDeviceProvider).when(
                      data: (devices) => ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) =>
                            buildListTile(devices[index], false),
                      ),
                      error: (error, stackTrace) =>
                          Center(child: Text(error.toString())),
                      loading: () => const CircularProgressIndicator(),
                    ),
              ),
              Expanded(
                child: ref.watch(getConnectedDeviceProvider).when(
                      data: (devices) => devices.isEmpty
                          ? const Text('No Connected Devices')
                          : ListView.builder(
                              itemCount: devices.length,
                              itemBuilder: (context, index) =>
                                  buildListTile(devices[index], true),
                            ),
                      error: (error, stackTrace) => Center(
                        child: Text(
                          error.toString(),
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile(BluetoothDevice device, bool leading) {
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
        leading: leading
            ? FutureBuilder<int>(
                future: device.readRssi(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    if (kDebugMode) {
                      print('No RSSI data available');
                    }
                    return const ListTile(
                      leading: Icon(Icons.error),
                      title: Text('No RSSI data'),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    if (kDebugMode) {
                      print('No RSSI data available');
                    }
                    return const ListTile(
                      leading: Icon(Icons.error),
                      title: Text('No RSSI data'),
                    );
                  } else {
                    final rssi = snapshot.data ??
                        -100; // Default to a weak signal if null
                    return getRangeIcon(rssi);
                  }
                },
              )
            : null, // Use function to determine range icon
        onTap: () => onTap(device),
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
