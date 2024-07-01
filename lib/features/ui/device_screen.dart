import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:logger/logger.dart';

import '../../core/common/connectio_status_bar.dart';
import '../../core/common/custom_toast.dart';
import '../../core/common/drawer.dart';
import '../../core/common/reusable_communication_button.dart';
import '../../core/common/reusable_icon_button.dart';
import '../../core/constants/ble_constants.dart';
import '../../core/constants/color_constant.dart';
import '../../core/constants/communication_constant.dart';
import '../../models/parameters_model.dart';
import '../repository/bluetooth_provider.dart';
import '../repository/parameters_provider.dart';

class DeviceScreen extends ConsumerStatefulWidget {
  final ParametersModel device;
  final int index;

  const DeviceScreen({
    super.key,
    required this.device,
    required this.index,
  });

  @override
  ConsumerState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  TextEditingController onTimeController = TextEditingController();
  TextEditingController offTimeController = TextEditingController();

  final Logger logger = Logger();

  String receivedData = '';

  double onTimeSliderValue = 0;
  double offTimeSliderValue = 0;

  @override
  void dispose() {
    if (kDebugMode) {
      print('Disposing MainScreen');
    }
    onTimeController.dispose();
    offTimeController.dispose();
    super.dispose();
  }

  Future<void> readDataFromDevice(BluetoothDevice device, String? uuid) async {
    if (uuid == null) return;
    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    var data = await bluetoothNotifier.readTheDataFromDevice(
        parametersModel: widget.device, uuid: uuid, context: context);
    if (mounted) {
      setState(() {
        receivedData = data;
      });
    }
  }

  void _updateUuids(String? readUuid, String? writeUuid) {
    ref
        .read(parametersModelProvider.notifier)
        .updateUuids(widget.index, readUuid, writeUuid);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final bluetoothNotifier = ref.read(bluetoothProvider.notifier);
    final updatedDevice = ref.watch(parametersModelProvider)[widget.index];
    logger.d('readUuid: ${updatedDevice.readUuid}');
    logger.d('writeUuid: ${updatedDevice.writeUuid}');

    readDataFromDevice(updatedDevice.device, updatedDevice.readUuid);

    return Scaffold(
      drawer: CustomDrawer(
        parametersModel: updatedDevice,
        onUpdateUuids: _updateUuids,
        index: widget.index,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Device: ${updatedDevice.device.platformName}',
            style: const TextStyle(
              fontFamily: 'Alatsi',
              color: ColorConstants.darkColor,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: ColorConstants.backgroundColorTwo,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: width * 0.1),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    height: width * 0.12,
                    width: width * 0.12,
                    decoration: BoxDecoration(
                      color: ColorConstants.backgroundColorTwo,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF747D8C).withOpacity(0.5),
                          blurRadius: 16,
                          offset: const Offset(8, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          blurRadius: 16,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/menu_icon.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width * 0.1),
                child: ConnectionStatusIndicator(
                  device: updatedDevice.device,
                ),
              )
            ],
          ),
          SizedBox(
            height: width * 0.1,
          ),
          Flexible(
            child: SizedBox(
              width: width * 0.7,
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          Center(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: ReusableCommunicationButton(
                            buttonText: 'S',
                            onPressed: () {
                              bluetoothNotifier.writeToDevice(
                                services: updatedDevice.services,
                                uuid: updatedDevice.writeUuid,
                                device: updatedDevice.device,
                                data:
                                    CommunicationConstant.shutterOnOffToggleKey,
                              );
                            },
                          ),
                        ),
                        Flexible(
                          child: ReusableCommunicationButton(
                            buttonText: '1',
                            mirror: false,
                            onPressed: () {
                              bluetoothNotifier.writeToDevice(
                                services: updatedDevice.services,
                                uuid: updatedDevice.writeUuid,
                                device: updatedDevice.device,
                                data: CommunicationConstant.relayOneToggleKey,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: ReusableCommunicationButton(
                            buttonText: '2',
                            mirror: false,
                            onPressed: () {
                              bluetoothNotifier.writeToDevice(
                                services: updatedDevice.services,
                                uuid: updatedDevice.writeUuid,
                                device: updatedDevice.device,
                                data: CommunicationConstant.relayTwoToggleKey,
                              );
                            },
                          ),
                        ),
                        Flexible(
                          child: ReusableCommunicationButton(
                            buttonText: '3',
                            onPressed: () {
                              bluetoothNotifier.writeToDevice(
                                services: updatedDevice.services,
                                uuid: updatedDevice.writeUuid,
                                device: updatedDevice.device,
                                data: CommunicationConstant.relayThreeToggleKey,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: ReusableIconButton(
                      onPressed: () {
                        bluetoothNotifier.writeToDevice(
                          services: updatedDevice.services,
                          uuid: updatedDevice.writeUuid,
                          device: updatedDevice.device,
                          data: CommunicationConstant.lightToggleKey,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.04,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ColorConstants.surface,
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF747D8C).withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(8, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(-8, -8),
                          ),
                        ],
                      ),
                      child: Container(
                        width: width * 0.8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorConstants.backgroundColorOne,
                              ColorConstants.backgroundColorTwo,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(35),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                            topLeft: Radius.circular(35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.04,
                                bottom: width * 0.02,
                                top: width * 0.02,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      ColorConstants.backgroundColorOne,
                                      ColorConstants.backgroundColorTwo,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.02),
                                      child: const Icon(CupertinoIcons.clock),
                                    ),
                                    SizedBox(
                                      width: width * 0.025,
                                    ),
                                    SizedBox(
                                      width: width * 0.3,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: width * 0.015,
                                          right: width * 0.08,
                                        ),
                                        child: TextField(
                                          controller: onTimeController,
                                          decoration: InputDecoration(
                                            hintText: 'On Time',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Alatsi',
                                              fontSize: width * 0.03,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              BLEConstants.onTimeReceivedFromBleDevice
                                  .toString(),
                              style: TextStyle(
                                  fontFamily: 'Alatsi', fontSize: width * 0.05),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: IconButton(
                                onPressed: () {
                                  if (kDebugMode) {
                                    print(
                                        'Sending data to BLE: ${onTimeController.text}');
                                  }
                                  if (onTimeController.text.trim().isEmpty) {
                                    logger.i('on Time Empty');
                                    CustomToast.showToast(
                                      'on Time Empty',
                                    );
                                  } else {
                                    bluetoothNotifier.writeToDevice(
                                      services: updatedDevice.services,
                                      uuid: updatedDevice.writeUuid,
                                      device: updatedDevice.device,
                                      data: CommunicationConstant.onTimeKey +
                                          onTimeController.text +
                                          CommunicationConstant
                                              .autoManualToggleKey,
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.send_sharp,
                                  size: width * 0.08,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF747D8C).withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(8, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 16,
                            offset: const Offset(-8, -8),
                          ),
                        ],
                      ),
                      child: Container(
                        width: width * 0.8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorConstants.backgroundColorOne,
                              ColorConstants.backgroundColorTwo,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(35),
                            bottomLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                            topLeft: Radius.circular(35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: width * 0.04,
                                bottom: width * 0.02,
                                top: width * 0.02,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      ColorConstants.backgroundColorOne,
                                      ColorConstants.backgroundColorTwo,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(width * 0.02),
                                      child: const Icon(CupertinoIcons.clock),
                                    ),
                                    SizedBox(
                                      width: width * 0.025,
                                    ),
                                    SizedBox(
                                      width: width * 0.3,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: width * 0.015,
                                          right: width * 0.08,
                                        ),
                                        child: TextField(
                                          controller: offTimeController,
                                          decoration: InputDecoration(
                                            hintText: 'Off Time',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Alatsi',
                                              fontSize: width * 0.03,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              BLEConstants.offTimeReceivedFromBleDevice
                                  .toString(),
                              style: TextStyle(
                                  fontFamily: 'Alatsi', fontSize: width * 0.05),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: IconButton(
                                onPressed: () {
                                  if (kDebugMode) {
                                    print(
                                        'Sending data to BLE: ${onTimeController.text}');
                                  }
                                  if (onTimeController.text.trim().isEmpty) {
                                    logger.i('on Time Empty');
                                    CustomToast.showToast(
                                      'on Time Empty',
                                    );
                                  } else {
                                    bluetoothNotifier.writeToDevice(
                                      services: updatedDevice.services,
                                      uuid: updatedDevice.writeUuid,
                                      device: updatedDevice.device,
                                      data: CommunicationConstant.offTimeKey +
                                          offTimeController.text +
                                          CommunicationConstant
                                              .autoManualToggleKey,
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.send_sharp,
                                  size: width * 0.08,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(top: width * 0.1, bottom: width * 0.1),
              child: FlutterToggleTab(
                width: width * 0.17,
                borderRadius: width * 0.03,
                selectedBackgroundColors: const [
                  ColorConstants.onColorOne,
                  ColorConstants.onColorTwo,
                  ColorConstants.onColorThree
                ],
                unSelectedBackgroundColors: const [ColorConstants.surface],
                selectedTextStyle: TextStyle(
                  fontFamily: 'Alatsi',
                  color: Colors.white,
                  fontSize: width * 0.05,
                ),
                unSelectedTextStyle: TextStyle(
                  fontFamily: 'Alatsi',
                  color: ColorConstants.darkColor,
                  fontSize: width * 0.05,
                ),
                labels: const ['Auto', 'Manual'],
                height: height * 0.07,
                selectedIndex: 0,
                selectedLabelIndex: (index) {
                  setState(() {
                    BLEConstants.autoManualToggleKey = index != 0;
                  });
                  bluetoothNotifier.writeToDevice(
                    services: updatedDevice.services,
                    uuid: updatedDevice.writeUuid,
                    device: updatedDevice.device,
                    data: CommunicationConstant.autoManualToggleKey,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
