import 'dart:async';
import 'package:flutter/foundation.dart' show VoidCallback, debugPrint;
import '../models/detection_result.dart';
import '../models/scan_history_record.dart';
import 'hive_service.dart';
import 'history_service.dart';
import 'mongo_service.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _hive = HiveService();
  final _history = HistoryService();
  final _connectivity = ConnectivityService();

  StreamSubscription? _connSub;

  VoidCallback? onSyncComplete;

  void init() {
    _connSub = _connectivity.onStatusChange.listen((isOnline) {
      if (isOnline) {
        trySyncPending();
      }
    });
  }

  Future<void> trySyncPending() async {
    if (_connectivity.isOffline) return;
    bool anySync = false;
    final pendingDetections = _hive.getPending();
    for (final item in pendingDetections) {
      final ok = await _uploadDetection(item);
      if (ok) await _hive.markAsSynced(item.id);
      if (ok) anySync = true;
    }

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
      final dynamic mongo = MongoService();
      await mongo.insertScanHistory(record);
      return true;
    } catch (e) {
      debugPrint('[SyncService] ScanHistory upload failed: $e');
      return false;
    }
  }

  void dispose() => _connSub?.cancel();
}
