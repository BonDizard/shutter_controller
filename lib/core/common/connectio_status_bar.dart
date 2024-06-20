import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/repository/ble_repository.dart'; // Assuming you use flutter_blue_plus

class ConnectionStatusIndicator extends ConsumerWidget {
  final BluetoothDevice device;

  const ConnectionStatusIndicator({Key? key, required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(connectionStateProvider(device)).when(
          data: (BluetoothConnectionState state) => Icon(
            state == BluetoothConnectionState.connected
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled,
            color: state == BluetoothConnectionState.connected
                ? Colors.green
                : Colors.red,
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
