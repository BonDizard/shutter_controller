import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/repository/bluetooth_provider.dart'; // Assuming you use flutter_blue_plus

class ConnectionStatusIndicator extends ConsumerWidget {
  final BluetoothDevice device;

  const ConnectionStatusIndicator({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(connectionStateProvider(device)).when(
          data: (BluetoothConnectionState state) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              state == BluetoothConnectionState.connected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: state == BluetoothConnectionState.connected
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          error: (error, stackTrace) =>
              const Icon(Icons.error, color: Colors.orange),
          loading: () => const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        );
  }
}
