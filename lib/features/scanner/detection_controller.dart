import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/detection_item.dart';
import '../../data/models/detection_result.dart';
import '../../data/repositories/detection_repository.dart';
import '../../data/services/ml_service.dart';

enum ScanMode { capture, live }

enum ScanState { idle, detecting, done, error }

class DetectionController extends ChangeNotifier with WidgetsBindingObserver {
  final MlService _mlService = MlService();
  final DetectionRepository _repository;

  DetectionController({required DetectionRepository repository})
    : _repository = repository {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  CameraController? cameraController;
  bool isInitialized = false;
  String? errorMessage;
  ScanMode mode = ScanMode.capture;
  ScanState scanState = ScanState.idle;
  List<DetectionItem> currentDetections = [];
  String? capturedImagePath;
  bool _isProcessingFrame = false;
  bool isFlashlightOn = false;
  bool isOverlayVisible = true;

  Future<void> _init() async {
    await Future.wait([_mlService.loadModel(), initCamera()]);
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = 'Tidak ada kamera yang terdeteksi.';
        notifyListeners();
        return;
      }

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();
      isInitialized = true;
      errorMessage = null;

      if (mode == ScanMode.live) _startLiveStream();
    } catch (e) {
      errorMessage = 'Gagal inisialisasi kamera: $e';
    }
    notifyListeners();
  }

  Future<void> setMode(ScanMode newMode) async {
    if (mode == newMode) return;
    mode = newMode;
    currentDetections = [];
    capturedImagePath = null;
    scanState = ScanState.idle;

    if (newMode == ScanMode.live) {
      _startLiveStream();
    } else {
      await _stopLiveStream();
    }
    notifyListeners();
  }

  void _startLiveStream() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessingFrame) return;
      _isProcessingFrame = true;
      try {
        final raw = await _mlService.detectFromCameraFrame(
          bytesList: image.planes.map((p) => p.bytes).toList(),
          imageWidth: image.width,
          imageHeight: image.height,
        );
        currentDetections = raw
            .map(
              (r) => DetectionItem.fromRaw(
                raw: r,
                imageWidth: image.width,
                imageHeight: image.height,
              ),
            )
            .toList();
        scanState = ScanState.done;
      } catch (_) {
        // Skip
      } finally {
        _isProcessingFrame = false;
        notifyListeners();
      }
    });
  }

  Future<void> _stopLiveStream() async {
    if (cameraController != null && cameraController!.value.isStreamingImages) {
      await cameraController!.stopImageStream();
    }
  }

  Future<void> captureAndDetect() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    scanState = ScanState.detecting;
    currentDetections = [];
    notifyListeners();

    try {
      final xFile = await cameraController!.takePicture();
      capturedImagePath = xFile.path;

      final imageBytes = await File(xFile.path).readAsBytes();
      final decoded = await decodeImageFromList(imageBytes);

      final raw = await _mlService.detectFromFile(
        imagePath: xFile.path,
        imageWidth: decoded.width,
        imageHeight: decoded.height,
      );

      currentDetections = raw
          .map(
            (r) => DetectionItem.fromRaw(
              raw: r,
              imageWidth: decoded.width,
              imageHeight: decoded.height,
            ),
          )
          .toList();

      scanState = ScanState.done;

      await _saveToHive(imagePath: xFile.path);
    } catch (e) {
      errorMessage = 'Deteksi gagal: $e';
      scanState = ScanState.error;
    }
    notifyListeners();
  }

  Future<void> _saveToHive({required String imagePath}) async {
    if (currentDetections.isEmpty) return;
    final best = currentDetections.reduce(
      (a, b) => a.confidence >= b.confidence ? a : b,
    );

    final record = DetectionResult(
      id: const Uuid().v4(),
      label: best.label,
      confidence: best.confidence,
      imagePath: imagePath,
      detectedAt: DateTime.now(),
      isSynced: false,
    );

    await _repository.save(record);
  }

  List<DetectionResult> get history => _repository.getAll();

  Future<void> toggleFlashlight() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    isFlashlightOn = !isFlashlightOn;
    try {
      await cameraController!.setFlashMode(
        isFlashlightOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      errorMessage = 'Gagal toggle lampu: $e';
    }
    notifyListeners();
  }

  void toggleOverlay() {
    isOverlayVisible = !isOverlayVisible;
    notifyListeners();
  }

  void resetScan() {
    currentDetections = [];
    capturedImagePath = null;
    scanState = ScanState.idle;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = cameraController;
    if (cam == null || !cam.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cam.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveStream();
    cameraController?.dispose();
    _mlService.close();
    super.dispose();
  }
}
