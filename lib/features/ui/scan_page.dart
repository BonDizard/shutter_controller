import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/features/ui/screen.dart';

import '../repository/ble_repository.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
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
                          .map((device) => ListTile(
                                title: Text(
                                  device.platformName,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ),
                                subtitle: Text(device.remoteId.toString()),
                                onTap: () => ref
                                    .read(bleRepositoryProvider.notifier)
                                    .connect(device: device, context: context),
                              ))
                          .toList(),
                    ),
                    error: (error, stackTrace) =>
                        Center(child: Text(error.toString())),
                    loading: () => const Text('search for devices!'),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        },
        child: const Icon(Icons.arrow_right),
      ),
    );
  }
}
