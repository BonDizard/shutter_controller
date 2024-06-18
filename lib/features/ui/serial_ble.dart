// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:shutter/core/utils.dart';
//
// List<BluetoothDiscoveryResult> results = List<BluetoothDiscoveryResult>();
//
// void startDiscovery() {
//   streamSubscription =
//       FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
//     results.add(r);
//   });
//
//   streamSubscription.onDone(() {
//     //Do something when the discovery process ends
//   });
// }
// BluetoothConnection connection;
//
// connect(String address) async {
//   try {
//     connection = await BluetoothConnection.toAddress(address);
//     print('Connected to the device');
//
//     connection.input.listen((Uint8List data) {
//       //Data entry point
//       print(ascii.decode(data));
//     })
//
//   } catch (exception) {
//     print('Cannot connect, exception occured');
//   }
// }
// class BluetoothSetupPage extends StatefulWidget {
//   const BluetoothSetupPage({Key? key}) : super(key: key);
//
//   @override
//   _BluetoothSetupPageState createState() => _BluetoothSetupPageState();
// }
//
// class _BluetoothSetupPageState extends State<BluetoothSetupPage> {
//   late BluetoothConnection _connection;
//   List<BluetoothDevice> devices = [];
//   bool _isConnecting = false; // Flag for connection status
//   TextEditingController sendingDataString = TextEditingController();
//   String receivedData = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _getPairedDevices();
//   }
//
//   Future<void> _getPairedDevices() async {
//     print('Getting paired devices...');
//     try {
//       devices = await FlutterBluetoothSerial.instance.getBondedDevices();
//       setState(() {}); // Update UI with new devices
//     } catch (error) {
//       print('Error getting paired devices: $error');
//     }
//   }
//
//   bool isConnecting = false;
//   bool isDisconnecting = false;
//   BluetoothConnection? connection;
//
//   Future<void> _connectToDevice(String address) async {
//     isConnecting = true;
//     BluetoothConnection.toAddress(address).then((_connection) {
//       print('Connected to the device');
//       connection = _connection;
//       setState(() {
//         isConnecting = false;
//         isDisconnecting = false;
//       });
//
//       connection!.input!.listen(_onDataReceived).onDone(() {
//         if (isDisconnecting) {
//           print('Disconnecting locally!');
//         } else {
//           print('Disconnected remotely!');
//         }
//         if (this.mounted) {
//           setState(() {});
//         }
//       });
//     }).catchError((error) {
//       print('Cannot connect, exception occured');
//       print(error);
//     });
//   }
//
//   String _messageBuffer = '';
//   String _messagePacket = '';
//
//   final StreamController<String> _messageController =
//       StreamController.broadcast();
//
//   void _onDataReceived(Uint8List data) {
//     // Create message if there is '\r\n' sequence
//     _messageBuffer += String.fromCharCodes(data);
//     while (_messageBuffer.contains('\r\n')) {
//       final int index = _messageBuffer.indexOf('\r\n');
//       _messagePacket = _messageBuffer.substring(0, index).trim();
//       _messageController.add(_messagePacket);
//       _messageBuffer = _messageBuffer.substring(index + 2);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Setup'),
//       ),
//       body: isConnecting
//           ? CircularProgressIndicator()
//           : Column(
//               children: [
//                 Center(
//                   child: _isConnecting
//                       ? CircularProgressIndicator() // Show progress indicator while connecting
//                       : Text('Bluetooth device:'),
//                 ),
//                 TextButton(
//                   onPressed: _getPairedDevices,
//                   child: Icon(Icons.refresh),
//                 ),
//                 ListView.builder(
//                   shrinkWrap: true, // Wrap content to avoid unnecessary space
//                   itemBuilder: (BuildContext context, int index) {
//                     BluetoothDevice device = devices[index];
//                     return ListTile(
//                       title: Text(device.name.toString()),
//                       subtitle: Text(device.address),
//                       onTap: () {
//                         _connectToDevice(device.address);
//                       },
//                     );
//                   },
//                   itemCount: devices.length,
//                 )
//               ],
//             ),
//     );
//   }
// }
