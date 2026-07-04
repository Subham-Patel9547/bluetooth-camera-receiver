import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/camera_provider.dart';
import '../widgets/status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!initialized) {
      initialized = true;

      Future.microtask(() {
        context.read<CameraProvider>().initializeCamera();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CameraProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Bluetooth Camera Receiver"),
      ),
      body: Column(
        children: [
          /// ================= CAMERA PREVIEW =================
          Expanded(
            flex: 5,
            child: provider.controller != null && provider.isInitialized
                ? AspectRatio(
                    aspectRatio: provider.controller!.value.aspectRatio,
                    child: CameraPreview(provider.controller!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          /// ================= INFO SECTION =================
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// TIMER
                  Text(
                    provider.recordingTime,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 1),

                  /// RECORDING STATUS
                  StatusCard(
                    title: "Recording Status",
                    status: provider.recordingStatus,
                    color: provider.isRecording ? Colors.red : Colors.green,
                    icon: provider.isRecording
                        ? Icons.fiber_manual_record
                        : Icons.check_circle,
                  ),

                  const SizedBox(height: 10),

                  /// SAVED VIDEO
                  if (provider.lastVideo.isNotEmpty)
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          provider.lastVideo,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  const SizedBox(height:5),

                  /// BLUETOOTH STATUS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 4),
                    decoration: BoxDecoration(
                      color: provider.bluetoothConnected
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: provider.bluetoothConnected
                            ? Colors.green
                            : Colors.orange,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          provider.bluetoothConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_searching,
                          color: provider.bluetoothConnected
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.bluetoothStatus,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: provider.bluetoothConnected
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
