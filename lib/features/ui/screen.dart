import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/core/constants/communication_constant.dart';

import '../repository/ble_repository.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  TextEditingController onTimeController = TextEditingController();
  TextEditingController offTimeController = TextEditingController();
  bool shutter = false;
  @override
  void initState() {
    super.initState();
    print('MainScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Devices'),
      ),
      body: ref.watch(getConnectedDeviceProvider).when(
            data: (devices) => ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];

                return Column(
                  children: [
                    Text(
                      device.platformName,
                      style: TextStyle(color: Colors.red, fontSize: 20),
                    ),
                    ref.watch(readDataFromBLEProvider(device)).when(
                      data: (data) {
                        print('Received data from BLE: $data');
                        return Text(data);
                      },
                      error: (error, stackTrace) {
                        print('Error reading data from BLE: $error');
                        return Center(child: Text(error.toString()));
                      },
                      loading: () {
                        print('Loading data from BLE');
                        return CircularProgressIndicator();
                      },
                    ),
                    Text('shutter:'),
                    Switch.adaptive(
                      value: shutter,
                      onChanged: (bool value) {
                        shutter = value;
                        ref.read(bleRepositoryProvider.notifier).write(
                              device: device,
                              data: CommunicationConstant.shutterOnOffToggleKey,
                            );
                      },
                    ),
                    TextField(
                      controller: onTimeController,
                      decoration: InputDecoration(
                        hintText: 'on time',
                        label: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            'on time',
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: offTimeController,
                      decoration: InputDecoration(
                        hintText: 'off time',
                        label: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            'off time',
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        print('Sending data to BLE: ${onTimeController.text}');
                        if (offTimeController.text.trim().isNotEmpty) {}
                        ref.read(bleRepositoryProvider.notifier).write(
                              device: device,
                              data: onTimeController.text +
                                  CommunicationConstant.onTimeKey,
                            );
                        ref.read(bleRepositoryProvider.notifier).write(
                              device: device,
                              data: offTimeController.text,
                            );
                      },
                      child: Text('Send'),
                    ),
                  ],
                );
              },
            ),
            error: (error, stackTrace) {
              print('Error getting connected devices: $error');
              return Center(child: Text(error.toString()));
            },
            loading: () {
              print('Loading connected devices');
              return CircularProgressIndicator();
            },
          ),
    );
  }

  @override
  void dispose() {
    print('Disposing MainScreen');
    onTimeController.dispose();
    offTimeController.dispose();
    super.dispose();
  }
}
