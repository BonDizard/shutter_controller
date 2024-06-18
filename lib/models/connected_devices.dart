import 'package:shutter/models/parameters_model.dart';

class ConnectedDevices {
  final List<ParametersModel> connectedDevices;

//<editor-fold desc="Data Methods">
  const ConnectedDevices({
    required this.connectedDevices,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConnectedDevices &&
          runtimeType == other.runtimeType &&
          connectedDevices == other.connectedDevices);

  @override
  int get hashCode => connectedDevices.hashCode;

  @override
  String toString() {
    return 'ConnectedDevices{' + ' connectedDevices: $connectedDevices,' + '}';
  }

  ConnectedDevices copyWith({
    List<ParametersModel>? connectedDevices,
  }) {
    return ConnectedDevices(
      connectedDevices: connectedDevices ?? this.connectedDevices,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'connectedDevices': this.connectedDevices,
    };
  }

  factory ConnectedDevices.fromMap(Map<String, dynamic> map) {
    return ConnectedDevices(
      connectedDevices: map['connectedDevices'] as List<ParametersModel>,
    );
  }

//</editor-fold>
}
