import 'package:flutter/material.dart';

class DetectionItem {
  /// Bounding box koordinat NORMALIZED (0.0–1.0)
  final Rect box;

  /// Label kelas penyakit sesuai labels.txt training Anda
  final String label;

  /// Skor kepercayaan model (0.0–1.0)
  final double confidence;

  const DetectionItem({
    required this.box,
    required this.label,
    required this.confidence,
  });

  /// Parse dari raw output flutter_vision.
  /// flutter_vision mengembalikan box [x1, y1, x2, y2] dalam piksel
  /// → dinormalisasi ke 0.0–1.0 agar painter bisa scale ke ukuran layar.
  factory DetectionItem.fromRaw({
    required Map<String, dynamic> raw,
    required int imageWidth,
    required int imageHeight,
  }) {
    final box = raw['box'] as List<dynamic>;
    final x1 = (box[0] as num).toDouble() / imageWidth;
    final y1 = (box[1] as num).toDouble() / imageHeight;
    final x2 = (box[2] as num).toDouble() / imageWidth;
    final y2 = (box[3] as num).toDouble() / imageHeight;
    final confidence = (box[4] as num).toDouble();

    return DetectionItem(
      box: Rect.fromLTRB(
        x1.clamp(0.0, 1.0),
        y1.clamp(0.0, 1.0),
        x2.clamp(0.0, 1.0),
        y2.clamp(0.0, 1.0),
      ),
      label: raw['tag'] as String? ?? 'Unknown',
      confidence: confidence,
    );
  }
}
