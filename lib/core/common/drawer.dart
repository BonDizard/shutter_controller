import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/models/parameters_model.dart';
import '../../features/repository/bluetooth_provider.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  final ParametersModel parametersModel;

  const CustomDrawer({super.key, required this.parametersModel});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  bool _showDropdowns = false;
  String? selectedWriteUuid;
  String? selectedReadUuid;
  List<Map<String, String>> uuidsWithProperties = [];

  @override
  void initState() {
    super.initState();
    _initializeWriteUuids();
  }

  void _initializeWriteUuids() {
    for (var service in widget.parametersModel.services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        String properties = '';
        if (c.properties.read) properties += 'Read ';
        if (c.properties.write) properties += 'Write ';
        if (c.properties.notify) properties += 'Notify ';
        if (c.properties.writeWithoutResponse) properties += 'WriteWR ';
        if (c.properties.indicate) properties += 'Indicate ';
        uuidsWithProperties
            .add({'uuid': c.uuid.toString(), 'properties': properties.trim()});
      }
    }
    if (uuidsWithProperties.isNotEmpty) {
      selectedWriteUuid = uuidsWithProperties.first['uuid'];
    }
    if (uuidsWithProperties.isNotEmpty) {
      selectedReadUuid = uuidsWithProperties.last['uuid'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(
      connectionStateProvider(widget.parametersModel.device),
    );
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);

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
              value: selectedWriteUuid,
              items: uuidsWithProperties.map((Map<String, String> uuidData) {
                return DropdownMenuItem<String>(
                  value: uuidData['uuid'],
                  child: Text(
                    '${uuidData['uuid']} (${uuidData['properties']})',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedWriteUuid = newValue;
                });
              },
            ),
            Text('Read UUID'),
            DropdownButton<String>(
              value: selectedReadUuid,
              items: uuidsWithProperties.map((Map<String, String> uuidData) {
                return DropdownMenuItem<String>(
                  value: uuidData['uuid'],
                  child: Text(
                    '${uuidData['uuid']} (${uuidData['properties']})',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedReadUuid = newValue;
                });
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
