import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_vision/flutter_vision.dart';

/// ml_service.dart
/// Simpan di: lib/data/services/ml_service.dart
///
/// Bertanggung jawab HANYA untuk komunikasi langsung dengan model YOLOv8.
/// best.pt / last.pt harus dikonversi dulu:
///   yolo export model=best.pt format=onnx
/// Lalu taruh hasil (best.onnx) di folder assets/

class MlService {
  final FlutterVision _vision = FlutterVision();
  bool _isLoaded = false;

  /// Ganti ke 'assets/last.onnx' untuk testing dengan last.pt
  static const String _modelAsset = 'assets/best.onnx';
  static const String _labelAsset = 'assets/labels.txt';

  /// Load model ke memori — panggil sekali saat controller init
  Future<void> loadModel() async {
    if (_isLoaded) return;
    await _vision.loadYoloModel(
      labels: _labelAsset,
      modelPath: _modelAsset,
      modelVersion: 'yolov8',
      quantization: false,
      numThreads: 2,
      useGpu: false,
    );
    _isLoaded = true;
  }

  /// Deteksi dari file foto (mode CAPTURE)
  Future<List<Map<String, dynamic>>> detectFromFile({
    required String imagePath,
    required int imageWidth,
    required int imageHeight,
    double confidenceThreshold = 0.40,
    double iouThreshold = 0.45,
  }) async {
    if (!_isLoaded) await loadModel();
    final imageBytes = await File(imagePath).readAsBytes();
    return await _vision.yoloOnImage(
      bytesList: imageBytes,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      iouThreshold: iouThreshold,
      confThreshold: confidenceThreshold,
      classThreshold: confidenceThreshold,
    );
  }

  /// Deteksi dari frame kamera (mode LIVE)
  Future<List<Map<String, dynamic>>> detectFromCameraFrame({
    required List<Uint8List> bytesList,
    required int imageWidth,
    required int imageHeight,
    double confidenceThreshold = 0.40,
    double iouThreshold = 0.45,
  }) async {
    if (!_isLoaded) await loadModel();
    return await _vision.yoloOnFrame(
      bytesList: bytesList,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      iouThreshold: iouThreshold,
      confThreshold: confidenceThreshold,
      classThreshold: confidenceThreshold,
    );
  }

  /// Lepaskan resource model
  Future<void> close() async {
    await _vision.closeYoloModel();
    _isLoaded = false;
  }
}
