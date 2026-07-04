import 'package:flutter/services.dart';

class NativeBluetoothService {
  static const MethodChannel _channel =
      MethodChannel("bluetooth_camera");

  /// Start Bluetooth RFCOMM Server
  Future<void> startServer() async {
    try {
      await _channel.invokeMethod("startServer");
    } catch (e) {
      print("Start Server Error : $e");
    }
  }

  /// Listen START / STOP commands
  void setCommandListener(
    Function(String command) onCommand,
  ) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onCommand") {
        final String command = call.arguments;

        print("Bluetooth Command => $command");

        onCommand(command);
      }
    });
  }
}