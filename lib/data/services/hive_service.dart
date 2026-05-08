import 'package:hive_flutter/hive_flutter.dart';
import '../models/detection_result.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String _boxName = 'detections';
  late Box<DetectionResult> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DetectionResultAdapter());
    _box = await Hive.openBox<DetectionResult>(_boxName);
  }

  Future<void> save(DetectionResult result) async {
    await _box.put(result.id, result);
  }

  List<DetectionResult> getPending() {
    return _box.values.where((r) => !r.isSynced).toList();
  }

  Future<void> markAsSynced(String id) async {
    final item = _box.get(id);
    if (item != null) {
      item.isSynced = true;
      await item.save();
    }
  }

  List<DetectionResult> getAll() =>
      _box.values.toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

  Future<void> delete(String id) async => await _box.delete(id);
}
