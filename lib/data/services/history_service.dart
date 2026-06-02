import 'package:hive/hive.dart';
import '../models/scan_history_record.dart';

/// Service untuk menyimpan dan membaca riwayat scan dari penyimpanan lokal (Hive).
class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _boxName = 'scan_history';

  static Future<void> openBox() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScanHistoryRecordAdapter());
    }
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ScanHistoryRecord>(_boxName);
    }
  }

  Box<ScanHistoryRecord> get _box => Hive.box<ScanHistoryRecord>(_boxName);

  /// Simpan satu record scan ke Hive (key = id record)
  Future<void> save(ScanHistoryRecord record) async {
    await _box.put(record.id, record);
  }

  /// Ambil semua record, diurutkan dari terbaru
  List<ScanHistoryRecord> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return list;
  }

  /// Ambil record berdasarkan tanggal tertentu (format 'yyyy-MM-dd')
  List<ScanHistoryRecord> getByDate(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final list =
        _box.values.where((r) => r.dateKey == key).toList();
    list.sort((a, b) => a.scannedAt.compareTo(b.scannedAt));
    return list;
  }

  /// Cek apakah ada data pada tanggal tertentu
  bool hasDataOnDate(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _box.values.any((r) => r.dateKey == key);
  }

  /// Hapus record berdasarkan id
  Future<void> delete(String id) async => await _box.delete(id);

  /// Ambil semua record yang BELUM tersinkronisasi ke server
  List<ScanHistoryRecord> getPending() {
    return _box.values.where((r) => !r.isSynced).toList();
  }

  /// Tandai record sebagai tersinkronisasi (setelah berhasil upload ke MongoDB)
  Future<void> markAsSynced(String id) async {
    final item = _box.get(id);
    if (item != null) {
      item.isSynced = true;
      await item.save();
    }
  }

  int get totalCount => _box.length;
  int get pendingCount => _box.values.where((r) => !r.isSynced).length;
}
