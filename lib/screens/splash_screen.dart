import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/native_bluetooth_service.dart';
import '../provider/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const platform = MethodChannel('bluetooth_camera_receiver');

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Native Kotlin server ko trigger karo chalu hone ke liye
      debugPrint("🔄 Triggering Native Bluetooth Server...");
      await platform.invokeMethod('startServer');
      debugPrint("✅ Native Bluetooth Server Active!");
    } catch (e) {
      debugPrint("Error starting server from splash: $e");
    }

    // 2. Server chalu hone ke baad 2-3 seconds ka delay dekar next screen par bhejo
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // ⚠️ Apni actual Camera Screen ka naam yahan likhein (e.g., HomeScreen ya CameraScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_connected, size: 90, color: Colors.blue),

            SizedBox(height: 20),

            Text(
              "Bluetooth Camera Receiver",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
