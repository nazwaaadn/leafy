import 'package:hive/hive.dart';

import '../models/detection_result.dart';

/// detection_repository.dart
/// Simpan di: lib/data/repositories/detection_repository.dart
///
/// Repository pattern — satu-satunya tempat yang boleh
/// baca/tulis Hive box untuk DetectionResult.
/// Controller tidak boleh akses Hive langsung.

class DetectionRepository {
  static const String _boxName = 'detection_results';

  // ── Buka box ──────────────────────────────────────────────────

  /// Panggil sekali saat app start (di main.dart)
  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<DetectionResult>(_boxName);
    }
  }

  Box<DetectionResult> get _box => Hive.box<DetectionResult>(_boxName);

  // ── Write ─────────────────────────────────────────────────────

  /// Simpan satu hasil deteksi
  Future<void> save(DetectionResult result) async {
    await _box.put(result.id, result);
  }

  /// Simpan banyak sekaligus
  Future<void> saveAll(List<DetectionResult> results) async {
    final map = {for (final r in results) r.id: r};
    await _box.putAll(map);
  }

  // ── Read ──────────────────────────────────────────────────────

  /// Semua riwayat, terbaru di atas
  List<DetectionResult> getAll() {
    return _box.values.toList().reversed.toList();
  }

  /// Cari satu berdasarkan id
  DetectionResult? getById(String id) {
    return _box.get(id);
  }

  /// Hanya yang belum tersinkronisasi ke server
  List<DetectionResult> getUnsynced() {
    return _box.values.where((r) => !r.isSynced).toList();
  }

  // ── Update ────────────────────────────────────────────────────

  /// Tandai sudah tersinkronisasi
  Future<void> markSynced(String id) async {
    final result = _box.get(id);
    if (result == null) return;
    result.isSynced = true;
    await result.save(); // HiveObject.save() — update in-place
  }

  /// Tandai banyak sekaligus
  Future<void> markAllSynced(List<String> ids) async {
    for (final id in ids) {
      await markSynced(id);
    }
  }

  // ── Delete ────────────────────────────────────────────────────

  /// Hapus satu
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Hapus semua riwayat
  Future<void> clearAll() async {
    await _box.clear();
  }

  // ── Info ──────────────────────────────────────────────────────

  int get totalCount => _box.length;

  int get unsyncedCount => getUnsynced().length;
}