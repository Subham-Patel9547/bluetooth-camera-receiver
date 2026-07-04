import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    final result = await permissions.request();

    return result.values.every((status) => status.isGranted);
  }
}