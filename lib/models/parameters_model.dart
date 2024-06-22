import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ParametersModel {
  final BluetoothDevice device;
  final List<BluetoothService> services;
  final String readUuid;
  final String writeUuid;

//<editor-fold desc="Data Methods">
  const ParametersModel({
    required this.device,
    required this.services,
    required this.readUuid,
    required this.writeUuid,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParametersModel &&
          runtimeType == other.runtimeType &&
          device == other.device &&
          services == other.services &&
          readUuid == other.readUuid &&
          writeUuid == other.writeUuid);

  @override
  int get hashCode =>
      device.hashCode ^
      services.hashCode ^
      readUuid.hashCode ^
      writeUuid.hashCode;

  @override
  String toString() {
    return 'ParametersModel{ device: $device, services: $services, readUuid: $readUuid, writeUuid: $writeUuid,}';
  }

  ParametersModel copyWith({
    BluetoothDevice? device,
    List<BluetoothService>? services,
    String? readUuid,
    String? writeUuid,
  }) {
    return ParametersModel(
      device: device ?? this.device,
      services: services ?? this.services,
      readUuid: readUuid ?? this.readUuid,
      writeUuid: writeUuid ?? this.writeUuid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device': device,
      'services': services,
      'readUuid': readUuid,
      'writeUuid': writeUuid,
    };
  }

  factory ParametersModel.fromMap(Map<String, dynamic> map) {
    return ParametersModel(
      device: map['device'] as BluetoothDevice,
      services: map['services'] as List<BluetoothService>,
      readUuid: map['readUuid'] as String,
      writeUuid: map['writeUuid'] as String,
    );
  }

//</editor-fold>
}
