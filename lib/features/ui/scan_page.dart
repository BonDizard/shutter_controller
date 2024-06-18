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
    // if (Platform.isAndroid) {
    //   print('is android');
    //   await device.requestMtu(100);
    // }
    // Simply print the name
    await device.connect(
      timeout: Duration(seconds: 10),
    );
    if (kDebugMode) {
      print(device.platformName);
    }

    try {
      // Store the BluetoothDevice before calling connect()
      // Discover services and characteristics
      List<BluetoothService> services = [];
      print('bluetoothService.isEmpty: ${bluetoothService.isEmpty}');

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

  bool autoManual = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(bleRepositoryProvider.notifier).scan();
              },
              child: const Text('Scan for devices'),
            ),
            Expanded(
              child: ref.watch(getScannedDeviceProvider).when(
                    data: (devices) => ListView(
                      children: devices
                          .map(
                            (device) => ListTile(
                              title: Text(
                                device.platformName.isEmpty
                                    ? 'N/A'
                                    : device.platformName,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                              subtitle: Text(device.remoteId.toString()),
                              onTap: () {
                                onTap(device);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    error: (error, stackTrace) =>
                        Center(child: Text(error.toString())),
                    loading: () => const Text('search for devices!'),
                  ),
            ),
            Expanded(
              child: ref.watch(getConnectedDeviceProvider).when(
                    data: (devices) {
                      return devices.isEmpty
                          ? Text('no Connected devices')
                          : ListView(
                              children: devices
                                  .map(
                                    (device) => ListTile(
                                      title: Text(
                                        device.platformName.isEmpty
                                            ? 'N/A'
                                            : device.platformName,
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      ),
                                      subtitle:
                                          Text(device.remoteId.toString()),
                                      onTap: () {
                                        onTap(device);
                                      },
                                    ),
                                  )
                                  .toList(),
                            );
                    },
                    error: (error, stackTrace) => Center(
                        child: Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    )),
                    loading: () => const Text(
                      'search for devices!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
