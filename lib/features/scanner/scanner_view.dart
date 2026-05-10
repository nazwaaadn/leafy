import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/detection_result.dart';
import 'detection_controller.dart';
import 'scanner_painter.dart';

/// scanner_view.dart
/// Simpan di: lib/features/scanner/scanner_view.dart
///
/// Arsitektur Stack layar:
///   Layer 0 ── CameraPreview  (live feed hardware)
///   Layer 1 ── CustomPaint    (bounding box via ScannerPainter)
///   Layer 2 ── UI controls    (FAB, info bar, mode toggle)

class ScannerView extends StatefulWidget {
  final DetectionController controller;

  const ScannerView({super.key, required this.controller});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  DetectionController get _ctrl => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) {
          if (!_ctrl.isInitialized) return _buildLoading();
          return _buildBody();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) => _buildFab(),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      title: const Text(
        'Deteksi Penyakit Daun',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
        // Mode toggle: CAPTURE ↔ LIVE
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) => TextButton.icon(
            icon: Icon(
              _ctrl.mode == ScanMode.capture
                  ? Icons.photo_camera
                  : Icons.videocam,
              color: Colors.greenAccent,
              size: 18,
            ),
            label: Text(
              _ctrl.mode == ScanMode.capture ? 'CAPTURE' : 'LIVE',
              style:
                  const TextStyle(color: Colors.greenAccent, fontSize: 12),
            ),
            onPressed: () => _ctrl.setMode(
              _ctrl.mode == ScanMode.capture
                  ? ScanMode.live
                  : ScanMode.capture,
            ),
          ),
        ),

        // Flashlight
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) => IconButton(
            icon: Icon(
              _ctrl.isFlashlightOn ? Icons.flash_on : Icons.flash_off,
              color: _ctrl.isFlashlightOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _ctrl.toggleFlashlight,
            tooltip: 'Lampu',
          ),
        ),

        // Overlay on/off
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) => IconButton(
            icon: Icon(
              _ctrl.isOverlayVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: _ctrl.toggleOverlay,
            tooltip: 'Overlay',
          ),
        ),

        // Riwayat
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: _showHistory,
          tooltip: 'Riwayat',
        ),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────────

  Widget _buildBody() {
    // Mode CAPTURE dan sudah ada foto hasil → tampilkan foto + bbox
    if (_ctrl.mode == ScanMode.capture && _ctrl.capturedImagePath != null) {
      return _buildCaptureResult();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 0: Camera preview
        Center(
          child: AspectRatio(
            aspectRatio: _ctrl.cameraController!.value.aspectRatio,
            child: CameraPreview(_ctrl.cameraController!),
          ),
        ),

        // Layer 1: Bounding box overlay
        if (_ctrl.isOverlayVisible)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerPainter(_ctrl.currentDetections),
            ),
          ),

        // Layer 2: Info bar live
        if (_ctrl.mode == ScanMode.live &&
            _ctrl.currentDetections.isNotEmpty)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: _buildLiveInfoBar(),
          ),

        // Layer 2: Overlay "mendeteksi..."
        if (_ctrl.scanState == ScanState.detecting)
          const _DetectingOverlay(),
      ],
    );
  }

  /// Tampilan setelah capture selesai: foto + bounding box + panel hasil
  Widget _buildCaptureResult() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Foto hasil
        Image.file(
          File(_ctrl.capturedImagePath!),
          fit: BoxFit.contain,
        ),

        // Bounding box di atas foto
        if (_ctrl.isOverlayVisible)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerPainter(_ctrl.currentDetections),
            ),
          ),

        // Panel hasil deteksi
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: _buildResultPanel(),
        ),

        // Tombol ulangi (kiri atas)
        Positioned(
          top: 8,
          left: 8,
          child: FloatingActionButton.small(
            heroTag: 'reset',
            backgroundColor: Colors.black54,
            onPressed: _ctrl.resetScan,
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────

  Widget _buildLiveInfoBar() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, color: Colors.greenAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              '${_ctrl.currentDetections.length} objek terdeteksi',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    if (_ctrl.currentDetections.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54.withValues(alpha: 0.54),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.6)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'Tidak ada penyakit terdeteksi',
                style: TextStyle(color: Colors.green, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Deteksi',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          const SizedBox(height: 8),
          ..._ctrl.currentDetections.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle,
                      color: Colors.greenAccent, size: 8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(d.label,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ),
                  Text(
                    '${(d.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────

  Widget _buildFab() {
    // Saat hasil capture tampil, FAB utama disembunyikan
    if (_ctrl.capturedImagePath != null) return const SizedBox.shrink();
    // Mode LIVE tidak butuh FAB
    if (_ctrl.mode == ScanMode.live) return const SizedBox.shrink();

    final isDetecting = _ctrl.scanState == ScanState.detecting;

    return FloatingActionButton.extended(
      heroTag: 'capture',
      backgroundColor: isDetecting ? Colors.grey : Colors.green,
      onPressed: isDetecting ? null : _ctrl.captureAndDetect,
      icon: isDetecting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.camera_alt),
      label: Text(isDetecting ? 'Mendeteksi...' : 'Ambil & Deteksi'),
    );
  }

  // ── Loading ───────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Memuat kamera & model YOLOv8...',
            style: TextStyle(color: Colors.white70),
          ),
          if (_ctrl.errorMessage != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _ctrl.errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: openAppSettings,
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Riwayat ───────────────────────────────────────────────────

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _HistorySheet(history: _ctrl.history),
    );
  }
}

// ── Widgets pendukung ─────────────────────────────────────────────

class _DetectingOverlay extends StatelessWidget {
  const _DetectingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 12),
            Text(
              'Menganalisis daun...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  final List<DetectionResult> history;
  const _HistorySheet({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Riwayat Deteksi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        if (history.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Belum ada riwayat deteksi.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, i) {
                final rec = history[i];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(rec.imagePath),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, _) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  title: Text(
                    rec.label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${(rec.confidence * 100).toStringAsFixed(1)}%  •  ${_fmt(rec.detectedAt)}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  trailing: rec.isSynced
                      ? const Icon(Icons.cloud_done,
                          color: Colors.greenAccent, size: 18)
                      : const Icon(Icons.cloud_off,
                          color: Colors.white38, size: 18),
                );
              },
            ),
          ),
      ],
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}
