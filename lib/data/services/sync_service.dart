import 'dart:async';
import 'package:flutter/foundation.dart' show VoidCallback, debugPrint;
import '../models/detection_result.dart';
import '../models/scan_history_record.dart';
import 'hive_service.dart';
import 'history_service.dart';
import 'mongo_service.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';

/// SyncService mengimplementasikan pola offline-first:
/// - Semua data scan selalu tersimpan dulu di Hive (lokal)
/// - Saat device online, pending records di-sync ke MongoDB
/// - Setelah berhasil upload, isSynced di-flip ke true di Hive
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _hive = HiveService();
  final _history = HistoryService();
  final _connectivity = ConnectivityService();

  StreamSubscription? _connSub;

  /// Callback opsional — dipanggil setelah sync selesai (untuk refresh UI)
  VoidCallback? onSyncComplete;

  void init() {
    _connSub = _connectivity.onStatusChange.listen((isOnline) {
      if (isOnline) {
        trySyncPending();
      }
    });
  }

  /// Coba sync semua pending records ke MongoDB.
  /// Aman dipanggil kapan saja; jika offline langsung return.
  Future<void> trySyncPending() async {
    if (_connectivity.isOffline) return;

    bool anySync = false;

    // Sync DetectionResult (raw detections box lama)
    final pendingDetections = _hive.getPending();
    for (final item in pendingDetections) {
      final ok = await _uploadDetection(item);
      if (ok) await _hive.markAsSynced(item.id);
      if (ok) anySync = true;
    }

    // Sync ScanHistoryRecord (scan_history box — yang muncul di UI history)
    final pendingHistory = _history.getPending();
    for (final record in pendingHistory) {
      final ok = await _uploadScanHistory(record);
      if (ok) await _history.markAsSynced(record.id);
      if (ok) anySync = true;
    }

    if (anySync) {
      onSyncComplete?.call();
    }
  }

  Future<bool> _uploadDetection(DetectionResult result) async {
    try {
      await MongoService().insertDetection(result);
      return true;
    } catch (e) {
      debugPrint('[SyncService] Detection upload failed: $e');
      return false;
    }
  }

  Future<bool> _uploadScanHistory(ScanHistoryRecord record) async {
    try {
      await MongoService().insertScanHistory(record);
      return true;
    } catch (e) {
      debugPrint('[SyncService] ScanHistory upload failed: $e');
      return false;
    }
  }

  void dispose() => _connSub?.cancel();
}
