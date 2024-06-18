import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ParametersModel {
  final bool shutterOnOffToggleValue;
  final bool autoManualToggleKey;
  final double onTimeKey;
  final double offTimeKey;
  final BluetoothDevice device;

//<editor-fold desc="Data Methods">
  const ParametersModel({
    required this.shutterOnOffToggleValue,
    required this.autoManualToggleKey,
    required this.onTimeKey,
    required this.offTimeKey,
    required this.device,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParametersModel &&
          runtimeType == other.runtimeType &&
          shutterOnOffToggleValue == other.shutterOnOffToggleValue &&
          autoManualToggleKey == other.autoManualToggleKey &&
          onTimeKey == other.onTimeKey &&
          offTimeKey == other.offTimeKey &&
          device == other.device);

  @override
  int get hashCode =>
      shutterOnOffToggleValue.hashCode ^
      autoManualToggleKey.hashCode ^
      onTimeKey.hashCode ^
      offTimeKey.hashCode ^
      device.hashCode;

  @override
  String toString() {
    return 'ParametersModel{' +
        ' shutterOnOffToggleValue: $shutterOnOffToggleValue,' +
        ' autoManualToggleKey: $autoManualToggleKey,' +
        ' onTimeKey: $onTimeKey,' +
        ' offTimeKey: $offTimeKey,' +
        ' device: $device,' +
        '}';
  }

  ParametersModel copyWith({
    bool? shutterOnOffToggleValue,
    bool? autoManualToggleKey,
    double? onTimeKey,
    double? offTimeKey,
    BluetoothDevice? device,
  }) {
    return ParametersModel(
      shutterOnOffToggleValue:
          shutterOnOffToggleValue ?? this.shutterOnOffToggleValue,
      autoManualToggleKey: autoManualToggleKey ?? this.autoManualToggleKey,
      onTimeKey: onTimeKey ?? this.onTimeKey,
      offTimeKey: offTimeKey ?? this.offTimeKey,
      device: device ?? this.device,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shutterOnOffToggleValue': this.shutterOnOffToggleValue,
      'autoManualToggleKey': this.autoManualToggleKey,
      'onTimeKey': this.onTimeKey,
      'offTimeKey': this.offTimeKey,
      'device': this.device,
    };
  }

  factory ParametersModel.fromMap(Map<String, dynamic> map) {
    return ParametersModel(
      shutterOnOffToggleValue: map['shutterOnOffToggleValue'] as bool,
      autoManualToggleKey: map['autoManualToggleKey'] as bool,
      onTimeKey: map['onTimeKey'] as double,
      offTimeKey: map['offTimeKey'] as double,
      device: map['device'] as BluetoothDevice,
    );
  }

//</editor-fold>
}
