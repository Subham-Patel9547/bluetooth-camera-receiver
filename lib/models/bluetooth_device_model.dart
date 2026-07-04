class BluetoothDeviceModel {
  final String name;
  final String address;
  final bool isConnected;

  BluetoothDeviceModel({
    required this.name,
    required this.address,
    this.isConnected = false,
  });

  BluetoothDeviceModel copyWith({
    String? name,
    String? address,
    bool? isConnected,
  }) {
    return BluetoothDeviceModel(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "address": address,
      "isConnected": isConnected,
    };
  }

  factory BluetoothDeviceModel.fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceModel(
      name: map["name"] ?? "",
      address: map["address"] ?? "",
      isConnected: map["isConnected"] ?? false,
    );
  }
}