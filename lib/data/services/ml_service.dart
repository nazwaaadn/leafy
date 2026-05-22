import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_vision/flutter_vision.dart';

class MlService {
  final FlutterVision _vision = FlutterVision();
  bool _isLoaded = false;

  static const String _modelAsset = 'assets/models/best.tflite';
  static const String _labelAsset = 'assets/labels.txt';

  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      print("ML_SERVICE: Sedang memuat model $_modelAsset...");
      await _vision.loadYoloModel(
        labels: _labelAsset,
        modelPath: _modelAsset,
        modelVersion: 'yolov8',
        quantization: false,
        numThreads: 2,
        useGpu: false,
      );
      _isLoaded = true;
      print("ML_SERVICE_SUCCESS: Model $_modelAsset berhasil dimuat!");
    } catch (e) {
      print("ML_SERVICE_ERROR: Gagal memuat model: $e");
      print("ML_SERVICE_ERROR: CATATAN: flutter_vision HANYA mendukung format .tflite. Jika Anda menggunakan .onnx, silakan konversi terlebih dahulu ke .tflite.");
      _isLoaded = false;
    }
  }

  Future<List<Map<String, dynamic>>> detectFromFile({
    required String imagePath,
    required int imageWidth,
    required int imageHeight,
    double confidenceThreshold = 0.10,
    double iouThreshold = 0.45,
  }) async {
    if (!_isLoaded) {
      return [];
    }
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

  Future<List<Map<String, dynamic>>> detectFromCameraFrame({
    required List<Uint8List> bytesList,
    required int imageWidth,
    required int imageHeight,
    double confidenceThreshold = 0.10,
    double iouThreshold = 0.45,
  }) async {
    if (!_isLoaded) {
      return [];
    }
    return await _vision.yoloOnFrame(
      bytesList: bytesList,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
      iouThreshold: iouThreshold,
      confThreshold: confidenceThreshold,
      classThreshold: confidenceThreshold,
    );
  }

  Future<void> close() async {
    await _vision.closeYoloModel();
    _isLoaded = false;
  }
}
