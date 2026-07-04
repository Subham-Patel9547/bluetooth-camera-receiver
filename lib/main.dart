import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'provider/camera_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CameraProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ✅ FIX: MainActivity.kt ke companion object CHANNEL se exact match kiya
  static const String _channelName = "bluetooth_camera_receiver";
  static const MethodChannel _platform = MethodChannel(_channelName);

  @override
  void initState() {
    super.initState();
    // App start hote hi native commands ko listen karna shuru karein
    _initRemoteCommandListener();
  }

  void _initRemoteCommandListener() {
    _platform.setMethodCallHandler((MethodCall call) async {
      // ✅ FIX: MainActivity.kt ke invokeMethod("onCommand", ...) se exact match kiya
      if (call.method == "onCommand") {
        final String command = call.arguments as String;
        debugPrint("⚡ Flutter Received Remote Command: $command");

        if (!mounted) return;

        // Context ka use karke CameraProvider ke existing handler ko trigger karein
        final cameraProvider = context.read<CameraProvider>();

        // Aapke CameraProvider me command handling logic ko call kiya
        cameraProvider.handleBluetoothCommand(command);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bluetooth Camera Receiver",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const SplashScreen(),
    );
  }
}
