import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/features/repository/ble_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    return ref.watch(getConnectedDeviceProvider).when(
          data: (devices) {
            return Scaffold(
              body: devices.isEmpty
                  ? const Center(child: Text('No Connected Devices'))
                  : IndexedStack(
                      index: _selectedIndex,
                      children: List.generate(
                        devices.length,
                        (index) => DeviceScreen(
                          device: devices[index],
                          // Cycle through colors if there are more devices than colors
                        ),
                      ),
                    ),
              // Conditionally display the bottom navigation bar only if there are more than one device connected
              bottomNavigationBar: devices.length > 1
                  ? BottomNavigationBar(
                      items: List.generate(
                        devices.length,
                        (index) => BottomNavigationBarItem(
                          icon: const Icon(Icons.devices),
                          label: 'Device ${index + 1}',
                        ),
                      ),
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.amber[800],
                      onTap: _onItemTapped,
                    )
                  : null, // No bottom navigation bar if only one device is connected
            );
          },
          error: (error, stack) => Scaffold(
            body: Center(
              child: Text(error.toString()),
            ),
          ),
          loading: () => const Scaffold(
            body: Center(
              child: Text('loading connected device'),
            ),
          ),
        );
  }
}
