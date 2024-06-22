import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/core/common/loading.dart';
import '../../models/parameters_model.dart';
import '../repository/bluetooth_provider.dart';
import 'device_screen.dart';

class AllDevicePages extends ConsumerStatefulWidget {
  const AllDevicePages({super.key});

  @override
  ConsumerState createState() => _AllDevicePagesState();
}

class _AllDevicePagesState extends ConsumerState<AllDevicePages> {
  int _selectedIndex = 0; // State to keep track of the selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<ParametersModel> parameterModels = [];

  @override
  void initState() {
    super.initState();
    _fetchParameters();
  }

  Future<void> _fetchParameters() async {
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    final bluetoothState = ref.read(bluetoothProvider);
    final devices = bluetoothState.connectedDevices;

    List<ParametersModel> tempParameterModels = [];
    for (var device in devices) {
      tempParameterModels.add(
        await bluetoothNotifier.convertBluetoothDeviceToParameterModel(device),
      );
    }

    setState(() {
      parameterModels = tempParameterModels;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothState = ref.watch(bluetoothProvider);

    return Scaffold(
      body: bluetoothState.isLoading
          ? const Loader()
          : parameterModels.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Loader(),
                    Center(
                        child: Text(
                      'No Connected Devices',
                      style: Theme.of(context).textTheme.headlineLarge,
                    )),
                  ],
                )
              : IndexedStack(
                  index: _selectedIndex,
                  children: List.generate(
                    parameterModels.length,
                    (index) => DeviceScreen(
                      device: parameterModels[index],
                    ),
                  ),
                ),
      bottomNavigationBar: parameterModels.length > 1
          ? BottomNavigationBar(
              items: List.generate(
                parameterModels.length,
                (index) => BottomNavigationBarItem(
                  icon: const Icon(Icons.devices),
                  label: 'Device ${index + 1}',
                ),
              ),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            )
          : null,
    );
  }
}
