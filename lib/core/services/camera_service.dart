import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _cameraController;

  bool get isInitialized =>
      _cameraController != null && _cameraController!.value.isInitialized;

  /// Initialize Camera
  Future<void> initializeCamera() async {
    _cameras = await availableCameras();

    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception("No camera found");
    }

    final camera = _cameras!.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium, // 🔥 important fix (stability)
      enableAudio: true,
    );

    await _cameraController!.initialize();

    debugPrint("CAMERA READY");
  }

  Future<void> switchCamera(CameraLensDirection direction) async {
    final cameras = await availableCameras();

    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == direction,
      orElse: () => cameras.first,
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize();

    debugPrint("Switched camera to $direction");
  }

  /// Start Recording
  Future<void> startRecording() async {
    try {
      if (_cameraController == null) return;

      if (!_cameraController!.value.isInitialized) {
        debugPrint("Camera not initialized yet");
        return;
      }

      if (_cameraController!.value.isRecordingVideo) return;

      await _cameraController!.startVideoRecording();

      debugPrint("Recording Started");
    } catch (e, s) {
      debugPrint("Start Recording Error : $e");
      debugPrintStack(stackTrace: s);
    }
  }

  /// Stop Recording
  Future<XFile?> stopRecording() async {
    try {
      if (_cameraController == null) return null;

      if (!_cameraController!.value.isInitialized) return null;

      if (!_cameraController!.value.isRecordingVideo) return null;

      final XFile file = await _cameraController!.stopVideoRecording();

      debugPrint("Video Saved : ${file.path}");

      return file;
    } catch (e, s) {
      debugPrint("Stop Recording Error : $e");
      debugPrintStack(stackTrace: s);
      return null;
    }
  }

  /// Dispose Camera
  Future<void> disposeCamera() async {
    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      debugPrint("Dispose Error: $e");
    }
  }
}
