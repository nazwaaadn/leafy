import 'package:flutter/foundation.dart' show debugPrint;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/detection_result.dart';
import '../models/scan_history_record.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  Db? _db;
  Future<void>? _connectingFuture;

  Future<DbCollection> collection(String name) async {
    if (_db == null || !_db!.isConnected) await connect();
    return _db!.collection(name);
  }

  Future<DbCollection> _getCollection(String name) => collection(name);

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    if (_connectingFuture != null) return _connectingFuture!;
    _connectingFuture = _connectInternal();
    try {
      await _connectingFuture!;
    } finally {
      _connectingFuture = null;
    }
  }

  Future<void> _connectInternal() async {
    try {
      final uri = dotenv.env['MONGO_URI'] ?? dotenv.env['MONGODB_URI'];
      if (uri == null || uri.trim().isEmpty) {
        throw Exception('MONGO_URI tidak ada di .env');
      }
      if (_db != null) {
        try {
          await _db!.close();
        } catch (_) {}
        _db = null;
      }
      _db = await Db.create(uri.trim());
      await _db!.open().timeout(
        const Duration(seconds: 5),
        onTimeout: () =>
            throw Exception('Koneksi timeout. Cek whitelist IP Atlas.'),
      );
      debugPrint('[MongoDB] Connected');
    } catch (e) {
      _db = null;
      debugPrint('[MongoDB] Failed: $e');
      rethrow;
    }
  }

  // ─── DetectionResult (raw detections) ──────────────────────────────────────
  Future<void> insertDetection(DetectionResult result) async {
    final col = await _getCollection('detections');
    await col.insertOne({
      '_id': result.id,
      'label': result.label,
      'confidence': result.confidence,
      'imagePath': result.imagePath,
      'detectedAt': result.detectedAt.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getDetections() async {
    final col = await _getCollection('detections');
    return await col
        .find(where.sortBy('detectedAt', descending: true))
        .toList();
  }

  // ─── ScanHistoryRecord (history yang ditampilkan di app) ─────────────────────
  /// Upload satu ScanHistoryRecord ke MongoDB (upsert by _id).
  /// Dipanggil SyncService saat device kembali online.
  Future<void> insertScanHistory(ScanHistoryRecord record) async {
    final col = await _getCollection('scan_history');
    await col.replaceOne(
      where.eq('_id', record.id),
      {
        '_id': record.id,
        'conditionName': record.conditionName,
        'accuracyPercent': record.accuracyPercent,
        'isHealthy': record.isHealthy,
        'scannedAt': record.scannedAt.toIso8601String(),
        'syncedAt': DateTime.now().toIso8601String(),
      },
      upsert: true,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
