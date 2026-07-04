import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeBluetoothService {
  static const MethodChannel _channel =
      MethodChannel("bluetooth_camera_receiver");

  Future<void> startServer() async {
    await _channel.invokeMethod("startServer");
  }

  void setCommandListener(
    Function(String command) onCommand, {
    VoidCallback? onBluetoothConnected,
    VoidCallback? onBluetoothDisconnected,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onCommand":
          onCommand(call.arguments as String);
          break;

        case "onBluetoothConnected":
          onBluetoothConnected?.call();
          break;

        case "onBluetoothDisconnected":
          onBluetoothDisconnected?.call();
          break;
      }
    });
  }
}