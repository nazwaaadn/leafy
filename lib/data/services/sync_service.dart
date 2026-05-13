import 'dart:async';
import '../models/detection_result.dart';
import 'hive_service.dart';
import 'mongo_service.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _hive = HiveService();
  final _connectivity = ConnectivityService();

  StreamSubscription? _connSub;
  void init() {
    _connSub = _connectivity.onStatusChange.listen((isOnline) {
      if (isOnline) {
        trySyncPending();
      }
    });
  }

  Future<void> trySyncPending() async {
    if (_connectivity.isOffline) return;

    final pending = _hive.getPending();
    if (pending.isEmpty) return;

    for (final item in pending) {
      final success = await _uploadToMongoDB(item);
      if (success) {
        await _hive.markAsSynced(item.id);
      }
    }
  }

  Future<bool> _uploadToMongoDB(DetectionResult result) async {
    try {
      await MongoService().insertDetection(result);
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() => _connSub?.cancel();
}
