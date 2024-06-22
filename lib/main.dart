import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shutter/features/theme/theme_provider.dart';
import 'features/state/bluetooth_adapter_state_observer.dart';
import 'features/ui/bluetooth_off_screen.dart';
import 'features/ui/scan_page.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FlutterBlueApp(),
    ),
  );
}

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({super.key});

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanPage()
        : BluetoothOffScreen(bluetoothAdapterState: _adapterState);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dark Theme',

      themeMode: ThemeMode.system,

      //Our custom theme applied
      darkTheme: UiProvider.darkTheme,
      home: screen,
      theme: UiProvider.lightTheme,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}
