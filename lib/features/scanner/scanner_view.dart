import 'package:leafy_app/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/detection_result.dart';
import 'detection_controller.dart';
import 'scanner_painter.dart';

class ScannerView extends StatefulWidget {
  final DetectionController controller;

  const ScannerView({super.key, required this.controller});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  DetectionController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_handleStateChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(ScannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleStateChange);
      widget.controller.addListener(_handleStateChange);
    }
  }

  void _handleStateChange() {
    print("DEBUG: _handleStateChange called. State: ${_ctrl.scanState}");
    if (_ctrl.scanState == ScanState.done && mounted) {
      print("DEBUG: Scan done, triggering navigation to ResultView");
      _ctrl.scanState = ScanState.idle;
      context.push(AppRoutes.result, extra: _ctrl.currentDetections);
    }
  }

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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      title: const Text(
        'Deteksi Penyakit Daun',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      actions: [
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
              style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
            ),
            onPressed: () => _ctrl.setMode(
              _ctrl.mode == ScanMode.capture ? ScanMode.live : ScanMode.capture,
            ),
          ),
        ),

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

        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) => IconButton(
            icon: Icon(
              _ctrl.isOverlayVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: _ctrl.toggleOverlay,
            tooltip: 'Overlay',
          ),
        ),

        IconButton(
          icon: const Icon(Icons.image, color: Colors.white),
          onPressed: _ctrl.pickAndDetect,
          tooltip: 'Pilih dari Galeri',
        ),

        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: _showHistory,
          tooltip: 'Riwayat',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: 1 / _ctrl.cameraController!.value.aspectRatio,
            child: CameraPreview(_ctrl.cameraController!),
          ),
        ),

        if (_ctrl.isOverlayVisible)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerPainter(_ctrl.currentDetections),
            ),
          ),

        if (_ctrl.mode == ScanMode.live && _ctrl.currentDetections.isNotEmpty)
          Positioned(top: 8, left: 0, right: 0, child: _buildLiveInfoBar()),

        if (_ctrl.scanState == ScanState.detecting) const _DetectingOverlay(),
      ],
    );
  }

  Widget _buildCaptureResult() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 1 / _ctrl.cameraController!.value.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(_ctrl.capturedImagePath!), fit: BoxFit.cover),
                if (_ctrl.isOverlayVisible)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ScannerPainter(_ctrl.currentDetections),
                    ),
                  ),
              ],
            ),
          ),
        ),

        Positioned(bottom: 90, left: 0, right: 0, child: _buildResultPanel()),

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
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ..._ctrl.currentDetections.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.label,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${(d.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _buildFab() {
    if (_ctrl.capturedImagePath != null) return const SizedBox.shrink();
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
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.camera_alt),
      label: Text(isDetecting ? 'Mendeteksi...' : 'Ambil & Deteksi'),
    );
  }

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
              fontWeight: FontWeight.bold,
            ),
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
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${(rec.confidence * 100).toStringAsFixed(1)}%  •  ${_fmt(rec.detectedAt)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: rec.isSynced
                      ? const Icon(
                          Icons.cloud_done,
                          color: Colors.greenAccent,
                          size: 18,
                        )
                      : const Icon(
                          Icons.cloud_off,
                          color: Colors.white38,
                          size: 18,
                        ),
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
