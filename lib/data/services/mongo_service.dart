import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/detection_result.dart';

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

      print('[MongoDB] Connected');
    } catch (e) {
      _db = null;
      print('[MongoDB] Failed: $e');
      rethrow;
    }
  }

  Future<void> insertDetection(DetectionResult result) async {
    final col = await _getCollection('detections');
    await col.insertOne({
      '_id': result.id,
      'label': result.label,
      'confidence': result.confidence,
      'imagePath': result.imagePath,
      'detectedAt': result.detectedAt.toIso8601String(),
      'isSynced': true,
    });
  }

  Future<List<Map<String, dynamic>>> getDetections() async {
    final col = await _getCollection('detections');
    return await col
        .find(where.sortBy('detectedAt', descending: true))
        .toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>> getDetectionsGroupedByDate({
    String? userId,
  }) async {
    try {
      final col = await _getCollection('detections');

      final SelectorBuilder query = userId != null
          ? where.eq('userId', userId).sortBy('detectedAt', descending: true)
          : where.exists('_id').sortBy('detectedAt', descending: true);

      final docs = await col.find(query).toList();

      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final doc in docs) {
        final raw = doc['detectedAt']?.toString() ?? '';
        final dt = DateTime.tryParse(raw)?.toLocal();
        if (dt == null) continue;
        final key = _fmtDate(dt);
        grouped.putIfAbsent(key, () => []).add(doc);
      }

      return grouped;
    } catch (e) {
      print('[MongoService] getDetectionsGroupedByDate error: $e');
      return {};
    }
  }

  Future<({int healthy, int sick})> getDetectionStats({
    String? userId,
  }) async {
    try {
      final col = await _getCollection('detections');

      final SelectorBuilder baseQuery =
          userId != null ? where.eq('userId', userId) : where.exists('_id');

      final allDocs = await col.find(baseQuery).toList();

      int healthy = 0;
      int sick = 0;

      for (final doc in allDocs) {
        final label = (doc['label'] ?? '').toString().toLowerCase();
        if (label.contains('healthy')) {
          healthy++;
        } else {
          sick++;
        }
      }

      return (healthy: healthy, sick: sick);
    } catch (e) {
      print('[MongoService] getDetectionStats error: $e');
      return (healthy: -1, sick: -1);
    }
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}