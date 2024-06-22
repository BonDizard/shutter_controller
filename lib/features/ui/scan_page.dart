import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shutter/core/common/loading.dart';
import '../../core/constants/constants.dart';
import '../repository/bluetooth_provider.dart';
import 'all_device _dashboard.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  @override
  Widget build(BuildContext context) {
    final bluetoothState = ref.watch(bluetoothProvider);
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('SPEC - RULE'),
        backgroundColor: kSecondary,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (bluetoothState.isLoading)
                      const Loader()
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Available Devices',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '[${bluetoothState.scanResults.length} device(s) available]',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: bluetoothState.scanResults.length,
                                itemBuilder: (context, index) {
                                  final device =
                                      bluetoothState.scanResults[index].device;
                                  return buildConnectedDeviceTile(
                                      device, false);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        bluetoothNotifier.startScan();
                        bluetoothNotifier.fetchConnectedDevices();
                      },
                      child: const Text('Scan for Devices'),
                    ),
                    const SizedBox(
                        height: 8), // Add space between button and divider
                    const Divider(color: Colors.white),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Connected Devices:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '[${bluetoothState.connectedDevices.length} device(s) connected]',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: bluetoothState.connectedDevices.length,
                      itemBuilder: (context, index) {
                        final device = bluetoothState.connectedDevices[index];
                        return buildConnectedDeviceTile(device, true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(30.0),
        child: FloatingActionButton(
          backgroundColor: kTertiary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AllDevicePages(),
              ),
            );
          },
          child: const Icon(
            Icons.keyboard_arrow_right_sharp,
          ),
        ),
      ),
    );
  }

  Widget buildConnectedDeviceTile(BluetoothDevice device, bool connected) {
    final connectionStatus = ref.watch(connectionStateProvider(device));
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);

    Logger logger = Logger();

    return Card(
      elevation: 3,
      color: kTertiary,
      shadowColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: connected ? kTertiary : kSecondary,
          title: Text(
            device.platformName.isEmpty ? 'N/A' : device.platformName,
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: Text(device.remoteId.toString()),
          trailing: connectionStatus.when(
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
          leading: const Icon(Icons.bluetooth, color: Colors.blue),
          onTap: () {
            bluetoothNotifier.connectToDevice(device: device, context: context);
            logger.i('Connecting to ${device.platformName}');
          },
        ),
      ),
    );
  }

  Widget getRangeIcon(int rssi) {
    if (rssi > -60) {
      return Icon(
        Icons.signal_cellular_alt_rounded,
        color: kPrimary,
      );
    } else if (rssi > -70) {
      return Icon(
        Icons.signal_cellular_alt_2_bar_sharp,
        color: kPrimary,
      );
    } else if (rssi > -80) {
      return Icon(
        Icons.signal_cellular_alt_1_bar,
        color: kPrimary,
      );
    } else {
      return Icon(
        Icons.signal_cellular_connected_no_internet_0_bar,
        color: kPrimary,
      );
    }
  }
}
