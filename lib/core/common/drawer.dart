import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shutter/models/parameters_model.dart';
import '../../features/repository/bluetooth_provider.dart';
import '../../features/repository/parameters_provider.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  final ParametersModel parametersModel;
  final int index;
  final Function(String? readUuid, String? writeUuid) onUpdateUuids;

  const CustomDrawer({
    super.key,
    required this.parametersModel,
    required this.index,
    required this.onUpdateUuids,
  });

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  bool _showDropdowns = false;
  List<String> uuids = [];

  @override
  void initState() {
    super.initState();
    // Delay the state update
    Future.microtask(() {
      _initializeUuids();
    });
  }

  void _initializeUuids() {
    final uuidNotifier = ref.read(parametersModelProvider.notifier);

    for (var service in widget.parametersModel.services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        uuids.add(c.uuid.toString());
      }
    }

    if (uuids.isNotEmpty) {
      final initialWriteUuid = widget.parametersModel.writeUuid.isEmpty
          ? uuids.first
          : widget.parametersModel.writeUuid;
      final initialReadUuid = widget.parametersModel.readUuid.isEmpty
          ? uuids.last
          : widget.parametersModel.readUuid;

      uuidNotifier.updateUuids(widget.index, initialReadUuid, initialWriteUuid);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(
      connectionStateProvider(widget.parametersModel.device),
    );
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);

    final updatedDevice = ref.watch(parametersModelProvider)[widget.index];

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/app_logo/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Spec - scientific',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_indent_decrease),
            title: const Text('UUID'),
            onTap: () {
              setState(() {
                _showDropdowns = !_showDropdowns;
              });
            },
          ),
          if (_showDropdowns) ...[
            Text('Write UUID'),
            DropdownButton<String>(
              value: updatedDevice.writeUuid.isEmpty
                  ? null
                  : updatedDevice.writeUuid,
              hint: const Text('Select Write UUID'),
              items: uuids.map((uuid) {
                return DropdownMenuItem<String>(
                  value: uuid,
                  child: Text(
                    uuid,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                ref.read(parametersModelProvider.notifier).updateUuids(
                    widget.index, updatedDevice.readUuid, newValue);
                widget.onUpdateUuids(updatedDevice.readUuid, newValue);
              },
            ),
            Text('Read UUID'),
            DropdownButton<String>(
              value: updatedDevice.readUuid.isEmpty
                  ? null
                  : updatedDevice.readUuid,
              hint: const Text('Select Read UUID'),
              items: uuids.map((uuid) {
                return DropdownMenuItem<String>(
                  value: uuid,
                  child: Text(
                    uuid,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                ref.read(parametersModelProvider.notifier).updateUuids(
                    widget.index, newValue, updatedDevice.writeUuid);
                widget.onUpdateUuids(newValue, updatedDevice.writeUuid);
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.more_horiz),
            title: const Text('Connect more devices'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Disconnect'),
            onTap: () {
              bluetoothNotifier
                  .disconnectFromDevice(widget.parametersModel.device);
              Navigator.pop(context); // Close the drawer
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reconnect'),
            onTap: () {
              bluetoothNotifier.connectToDevice(
                device: widget.parametersModel.device,
                context: context,
              );
            },
          ),
          ListTile(
            title: connectionStatus.when(
              data: (BluetoothConnectionState state) => Text(
                state == BluetoothConnectionState.connected
                    ? 'Connected'
                    : 'Disconnected',
                style: TextStyle(
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
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
