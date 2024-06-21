import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/common/custom_toast.dart';
import '../../core/constants/constants.dart';
import '../../providers/bluetooth_provider.dart';

class ConnectBluetoothPage extends ConsumerWidget {
  const ConnectBluetoothPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bluetoothState = ref.watch(bluetoothProvider);
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    final Logger logger = Logger();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Connect Bluetooth Tracker'),
        backgroundColor: kSecondary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Bluetooth',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Switch(
                  value: bluetoothState.bluetoothEnabled,
                  onChanged: (value) {
                    bluetoothNotifier.toggleBluetooth(context, value);
                    logger.i('Bluetooth toggled: $value');
                    CustomToast.showToast(
                      value ? 'Bluetooth Enabled' : 'Bluetooth Disabled',
                    );
                  },
                  activeTrackColor: kTertiary,
                  inactiveTrackColor: Colors.grey,
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.grey,
                  thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey;
                    }
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.white;
                  }),
                ),
              ],
            ),
            const Divider(color: Colors.white),
            if (bluetoothState.isLoading)
              Center(child: CircularProgressIndicator(color: kTertiary))
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[${bluetoothState.connectedDevices.length} device(s) connected]',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        'Connected Devices',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: bluetoothState.connectedDevices.length,
                        itemBuilder: (context, index) {
                          final device = bluetoothState.connectedDevices[index];
                          return Card(
                            color: kTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  bluetoothNotifier
                                      .disconnectFromDevice(device);
                                  logger.i(
                                      'Disconnected from ${device.platformName}');
                                  CustomToast.showToast(
                                    'Disconnected from ${device.platformName}',
                                  );
                                },
                                child: ListTile(
                                  title: Text(
                                    device.platformName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    device.remoteId.toString(),
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: const Icon(
                                    Icons.signal_cellular_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        '[${bluetoothState.scanResults.length} device(s) available]',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        'Available Devices',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: bluetoothState.scanResults.length,
                        itemBuilder: (context, index) {
                          final device =
                              bluetoothState.scanResults[index].device;
                          return Card(
                            color: kPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  bluetoothNotifier.connectToDevice(device);
                                  logger.i(
                                      'Connecting to ${device.platformName}');
                                  CustomToast.showToast(
                                    'Connecting to ${device.platformName}',
                                  );
                                },
                                child: ListTile(
                                  title: Text(
                                    device.platformName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    device.remoteId.toString(),
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: const Icon(
                                    Icons.signal_cellular_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      backgroundColor: kPrimary,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bluetoothNotifier.startScan();
          bluetoothNotifier.fetchConnectedDevices();

          // Delay for 5 seconds
          await Future.delayed(const Duration(seconds: 5));

          // bluetoothNotifier.stopScan();
        },
      ),
    );
  }
}
