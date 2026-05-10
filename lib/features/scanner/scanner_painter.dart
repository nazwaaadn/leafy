import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../data/models/detection_item.dart';

/// scanner_painter.dart
/// Simpan di: lib/features/scanner/scanner_painter.dart
///
/// CustomPainter untuk menggambar bounding box YOLOv8
/// di atas CameraPreview atau foto statis.
/// Pattern sama dengan DamagePainter di modul zip.

class ScannerPainter extends CustomPainter {
  final List<DetectionItem> detections;

  /// Warna per kelas — sesuaikan dengan label training Anda di labels.txt
  static const Map<String, Color> _classColors = {
    'Leaf Blight':    Color(0xFFE53935), // Merah   – parah
    'Leaf Spot':      Color(0xFFFB8C00), // Oranye  – sedang
    'Powdery Mildew': Color(0xFFFDD835), // Kuning  – ringan
    'Rust':           Color(0xFF8D6E63), // Coklat
    'Mosaic Virus':   Color(0xFF7B1FA2), // Ungu
    'Healthy':        Color(0xFF43A047), // Hijau   – sehat
  };

  const ScannerPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) {
      _drawScanGuide(canvas, size);
      return;
    }
    for (final det in detections) {
      _drawBox(canvas, size, det);
    }
  }

  // ── Crosshair saat belum ada deteksi ─────────────────────────

  void _drawScanGuide(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 40.0;
    const arm = 60.0;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), paint);
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), paint);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.green.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    _paintLabel(
      canvas,
      'Arahkan kamera ke daun tanaman...',
      Offset(cx - 130, cy + r + 12),
      Colors.white,
    );
  }

  // ── Bounding box + label ──────────────────────────────────────

  void _drawBox(Canvas canvas, Size size, DetectionItem det) {
    // Denormalisasi koordinat ke piksel layar
    final rect = Rect.fromLTRB(
      det.box.left   * size.width,
      det.box.top    * size.height,
      det.box.right  * size.width,
      det.box.bottom * size.height,
    );

    final color = _colorForLabel(det.label);

    // Shadow
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4),
    );

    // Box utama
    canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Corner accent (sudut tebal)
    _drawCorners(canvas, rect, color);

    // Label
    _drawBoxLabel(canvas, rect, det, color);
  }

  void _drawCorners(Canvas canvas, Rect rect, Color color) {
    const len = 16.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Kiri atas
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), p);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), p);
    // Kanan atas
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-len, 0), p);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, len), p);
    // Kiri bawah
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(len, 0), p);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -len), p);
    // Kanan bawah
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-len, 0), p);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -len), p);
  }

  void _drawBoxLabel(Canvas canvas, Rect box, DetectionItem det, Color color) {
    final pct = (det.confidence * 100).toStringAsFixed(1);
    final text = ' ${det.label} · $pct% ';
    const fontSize = 13.0;
    const padding = 4.0;

    final tp = _textPainter(text, Colors.white, fontSize);
    tp.layout();

    // Posisi label: di atas box; geser ke bawah jika terpotong tepi atas
    double labelTop = box.top - tp.height - padding * 2;
    if (labelTop < 0) labelTop = box.bottom + padding;

    final bgRect = Rect.fromLTWH(
      box.left,
      labelTop,
      tp.width + padding * 2,
      tp.height + padding * 2,
    );

    // Background label
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      Paint()..color = color.withOpacity(0.85),
    );

    tp.paint(canvas, Offset(bgRect.left + padding, bgRect.top + padding));
  }

  // ── Helpers ───────────────────────────────────────────────────

  TextPainter _textPainter(String text, Color color, double fontSize) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  void _paintLabel(Canvas canvas, String text, Offset offset, Color color) {
    final tp = _textPainter(text, color, 13);
    tp.layout();
    tp.paint(canvas, offset);
  }

  Color _colorForLabel(String label) =>
      _classColors[label] ?? const Color(0xFF00B0FF);

  @override
  bool shouldRepaint(covariant ScannerPainter oldDelegate) =>
      oldDelegate.detections != detections;
}
