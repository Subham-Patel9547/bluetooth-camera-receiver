import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../core/services/camera_service.dart';
import '../core/services/permission_service.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import '../core/services/native_bluetooth_service.dart';

class CameraProvider extends ChangeNotifier {
  final CameraService _service = CameraService();
  final PermissionService _permissionService = PermissionService();
  final NativeBluetoothService _bluetoothService = NativeBluetoothService();

  CameraLensDirection _currentLens = CameraLensDirection.back;
  CameraLensDirection get currentLens => _currentLens;

  String lastVideo = "";
  String recordingStatus = "Ready";

  bool isInitialized = false;
  bool isRecording = false;
  bool isPaused = false;
  bool _isCameraBusy = false;

  bool bluetoothConnected = false;

  Timer? _timer;
  int seconds = 0;

  CameraProvider() {
    _bluetoothService.setCommandListener(
      (command) {
        handleBluetoothCommand(command);
      },
      onBluetoothConnected: () {
        bluetoothConnected = true;
        notifyListeners();
      },
      onBluetoothDisconnected: () {
        bluetoothConnected = false;
        notifyListeners();
      },
    );
  }

  void updateBluetoothStatus(bool connected) {
    bluetoothConnected = connected;
    notifyListeners();
  }

  String get recordingTime {
    final minute = (seconds ~/ 60).toString().padLeft(2, '0');
    final second = (seconds % 60).toString().padLeft(2, '0');
    return "$minute:$second";
  }

  String get bluetoothStatus {
    return bluetoothConnected
        ? "Bluetooth Connected"
        : "Waiting for Bluetooth Commands...";
  }

  /// Getter to access controller safely from the service
  CameraController? get controller => _service.controller;

  Future<void> initializeCamera() async {
    if (_isCameraBusy || isInitialized) return;

    _isCameraBusy = true;
    final granted = await _permissionService.requestPermissions();

    if (!granted) {
      _isCameraBusy = false;
      recordingStatus = "Permissions Denied";
      notifyListeners();
      return;
    }

    await _service.initializeCamera();
    isInitialized = _service.isInitialized;
    _isCameraBusy = false;
    notifyListeners();
  }

  // 🕒 Timer start karne ke liye helper function
  void _startTimer() {
    _timer?.cancel();
    seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds++;
      notifyListeners();
    });
  }

  /// ✅ METHOD CHANNEL SE AA RAHE COMMANDS KO YAHAN HANDLE KAREIN
  void handleBluetoothCommand(String command) async {
    String cleanCmd = command.trim().toUpperCase();
    print("Processing Camera Command: $cleanCmd");

    // Runtime controller reference check block
    final currentController = controller;
    if (currentController == null || !isInitialized) {
      print("Camera not initialized yet!");
      return;
    }

    try {
      switch (cleanCmd) {
        case "START":
          if (!isRecording) {
            // ✅ FIX: Used correct controller reference from service
            await currentController.startVideoRecording();
            isRecording = true;
            isPaused = false;
            recordingStatus = "Recording...";
            _startTimer(); // Timer chalu kiya
            notifyListeners();
          }
          break;

        case "PAUSE":
          if (isRecording && !isPaused) {
            // ✅ FIX: Correct controller reference used for pausing
            await currentController.pauseVideoRecording();
            isPaused = true;
            _timer?.cancel(); // Timer ko temporary roka
            recordingStatus = "Paused";
            print("Video Recording Paused");
            notifyListeners();
          }
          break;

        case "RESUME":
          if (isRecording && isPaused) {
            // ✅ FIX: Correct controller reference used for resuming
            await currentController.resumeVideoRecording();
            isPaused = false;
            recordingStatus = "Recording...";
            // Timer ko wahin se aage badhaya
            _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
              seconds++;
              notifyListeners();
            });
            print("Video Recording Resumed");
            notifyListeners();
          }
          break;

        case "STOP":
          if (isRecording) {
            // Remote button par bhi screen control wala solid save logic link kar diya
            await stopRecording();
          }
          break;

        case "SWITCH":
          if (!isRecording) {
            await switchCamera();
          }
          break;
      }
    } catch (e) {
      print("Error in executing camera actions: $e");
    }
  }

  // 💾 Video close aur Gallery me auto-save karne ka core logic
  Future<void> stopRecording() async {
    try {
      _timer?.cancel();
      recordingStatus = "Saving Video...";
      notifyListeners();

      // Service ka use karke official flow se recording stop kari
      final file = await _service.stopRecording();

      isRecording = false;
      isPaused = false;

      seconds = 0;
      notifyListeners();

      if (file != null) {
        // Automatically save to physical gallery path
        await GallerySaver.saveVideo(file.path);
        lastVideo = "Saved: ${file.name}";
        recordingStatus = "Video Saved!";
      } else {
        recordingStatus = "Ready";
      }

      notifyListeners();
    } catch (e) {
      print("Error stopping recording: $e");
      recordingStatus = "Ready";
      isRecording = false;
      isPaused = false;
      notifyListeners();
    }
  }

  Future<void> switchCamera() async {
    final cameras = await availableCameras();
    if (cameras.length < 2) return;

    _currentLens = _currentLens == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    await _service.switchCamera(_currentLens);
    isInitialized = _service.isInitialized;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.disposeCamera();
    super.dispose();
  }
}
