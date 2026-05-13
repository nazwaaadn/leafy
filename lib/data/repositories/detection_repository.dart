import 'package:hive/hive.dart';

import '../models/detection_result.dart';

class DetectionRepository {
  static const String _boxName = 'detection_results';

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<DetectionResult>(_boxName);
    }
  }

  Box<DetectionResult> get _box => Hive.box<DetectionResult>(_boxName);
  Future<void> save(DetectionResult result) async {
    await _box.put(result.id, result);
  }

  Future<void> saveAll(List<DetectionResult> results) async {
    final map = {for (final r in results) r.id: r};
    await _box.putAll(map);
  }

  List<DetectionResult> getAll() {
    return _box.values.toList().reversed.toList();
  }

  DetectionResult? getById(String id) {
    return _box.get(id);
  }

  List<DetectionResult> getUnsynced() {
    return _box.values.where((r) => !r.isSynced).toList();
  }

  Future<void> markSynced(String id) async {
    final result = _box.get(id);
    if (result == null) return;
    result.isSynced = true;
    await result.save();
  }

  Future<void> markAllSynced(List<String> ids) async {
    for (final id in ids) {
      await markSynced(id);
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  int get totalCount => _box.length;
  int get unsyncedCount => getUnsynced().length;
}