import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:leafy_app/data/models/detection_result.dart';
import 'package:leafy_app/data/models/scan_history_record.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';
import 'package:leafy_app/data/services/mongo_service.dart';
import 'package:leafy_app/data/services/session_service.dart';
import 'package:leafy_app/data/services/sync_service.dart';

enum SyncStatus { local, synced }

enum HealthStatus { healthy, diseased }

/// Wrapper ringan agar history_view.dart tetap kompatibel
class ScanRecord {
  final String logId;
  final String conditionName;
  final String time;
  final int accuracyPercent;
  final SyncStatus syncStatus;
  final HealthStatus healthStatus;

  const ScanRecord({
    required this.logId,
    required this.conditionName,
    required this.time,
    required this.accuracyPercent,
    required this.syncStatus,
    required this.healthStatus,
  });

  /// Konversi dari ScanHistoryRecord (Hive model typeId:1)
  factory ScanRecord.fromHive(ScanHistoryRecord r) {
    final dt = r.scannedAt.toLocal();
    return ScanRecord(
      logId: '#${r.id.substring(0, r.id.length.clamp(0, 6)).toUpperCase()}',
      conditionName: r.conditionName,
      time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      accuracyPercent: r.accuracyPercent.round(),
      syncStatus: r.isSynced ? SyncStatus.synced : SyncStatus.local,
      healthStatus: r.isHealthy ? HealthStatus.healthy : HealthStatus.diseased,
    );
  }

  /// Konversi dari DetectionResult (Hive model typeId:0)
  factory ScanRecord.fromDetectionResult(DetectionResult r) {
    final dt = r.detectedAt.toLocal();
    final label = r.label;
    return ScanRecord(
      logId: '#${r.id.substring(0, r.id.length.clamp(0, 6)).toUpperCase()}',
      conditionName: label.isEmpty ? 'Tidak Diketahui' : label,
      time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      accuracyPercent: (r.confidence * 100).round().clamp(0, 100),
      syncStatus: r.isSynced ? SyncStatus.synced : SyncStatus.local,
      healthStatus: label.toLowerCase().contains('healthy')
          ? HealthStatus.healthy
          : HealthStatus.diseased,
    );
  }
}

class HistoryController extends GetxController {
  final MongoService _mongo = MongoService();
  final ConnectivityService _connectivity = ConnectivityService();
  final SessionService _session = SessionService();

  final Rx<DateTime> activeMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final ScrollController calendarScrollController = ScrollController();

  final RxMap<String, List<ScanRecord>> _scanData =
      <String, List<ScanRecord>>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Daftarkan callback ke SyncService agar UI otomatis refresh setelah sync
    SyncService().onSyncComplete = () {
      _loadData();
    };
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      if (_connectivity.isOffline) {
        _loadFromHive();
      } else {
        await _loadFromMongo();
      }
    } catch (e) {
      print('[HistoryController] load error: $e');
      hasError.value = true;
      _loadFromHive();
    } finally {
      isLoading.value = false;
      _updatePendingCount();
    }
  }

  Future<void> _loadFromMongo() async {
    // Baca dari collection 'scan_history' (bukan 'detections')
    final grouped = await _mongo.getScanHistoryGroupedByDate(
      userId: _session.currentUser?.id,
    );

    if (grouped.isEmpty) {
      _loadFromHive();
      return;
    }

    final Map<String, List<ScanRecord>> result = {};
    grouped.forEach((dateKey, docs) {
      result[dateKey] = docs.map(_mongoDocToScanRecord).toList();
    });

    _scanData.value = result;
  }

  void _loadFromHive() {
    try {
      final Map<String, List<ScanRecord>> result = {};

      // Prioritaskan ScanHistoryRecord box (typeId:1) jika ada
      if (Hive.isBoxOpen('scan_history')) {
        final box = Hive.box<ScanHistoryRecord>('scan_history');
        for (final item in box.values) {
          final dateKey = _fmt(item.scannedAt.toLocal());
          result.putIfAbsent(dateKey, () => []).add(ScanRecord.fromHive(item));
        }
      }

      // Fallback ke DetectionResult box (typeId:0) jika scan_history kosong
      if (result.isEmpty && Hive.isBoxOpen('detections')) {
        final box = Hive.box<DetectionResult>('detections');
        for (final item in box.values) {
          final dateKey = _fmt(item.detectedAt.toLocal());
          result.putIfAbsent(dateKey, () => []).add(ScanRecord.fromDetectionResult(item));
        }
      }

      for (final key in result.keys) {
        result[key]!.sort((a, b) => b.time.compareTo(a.time));
      }

      _scanData.value = result;
    } catch (e) {
      print('[HistoryController] Hive fallback error: $e');
      _scanData.value = {};
    }
  }

  ScanRecord _mongoDocToScanRecord(Map<String, dynamic> doc) {
    // Baca field dari collection scan_history
    final conditionName = (doc['conditionName'] ?? '').toString();
    final accuracy = (doc['accuracyPercent'] ?? 0.0) as num;
    final rawIsHealthy = doc['isHealthy'];
    final isHealthy = rawIsHealthy == true ||
        rawIsHealthy?.toString().toLowerCase() == 'true' ||
        conditionName.toLowerCase() == 'sehat' ||
        conditionName.toLowerCase().contains('healthy');
    final rawDate = doc['scannedAt']?.toString() ?? '';
    final dt = DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now();
    final isSynced = doc['isSynced'] ?? true;

    return ScanRecord(
      logId: _shortId(doc['_id']?.toString() ?? ''),
      conditionName: conditionName.isEmpty ? 'Tidak Diketahui' : conditionName,
      time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      accuracyPercent: accuracy.round().clamp(0, 100),
      syncStatus: isSynced ? SyncStatus.synced : SyncStatus.local,
      healthStatus: isHealthy ? HealthStatus.healthy : HealthStatus.diseased,
    );
  }


  String _shortId(String id) {
    if (id.isEmpty) return '#???';
    final clean = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return '#${clean.substring(0, clean.length.clamp(0, 6)).toUpperCase()}';
  }

  /// Hitung berapa banyak data lokal yang belum tersinkron
  void _updatePendingCount() {
    int count = 0;
    try {
      if (Hive.isBoxOpen('scan_history')) {
        final box = Hive.box<ScanHistoryRecord>('scan_history');
        for (final r in box.values) {
          if (!r.isSynced) count++;
        }
      }
      if (Hive.isBoxOpen('detections')) {
        final box = Hive.box<DetectionResult>('detections');
        for (final r in box.values) {
          if (!r.isSynced) count++;
        }
      }
    } catch (_) {}
    pendingCount.value = count;
  }

  /// Muat ulang data riwayat (dipanggil setelah simpan dari ResultView)
  Future<void> refreshHistory() => _loadData();

  String _labelToConditionName(String label) {
    if (label.toLowerCase().contains('healthy')) return 'Sehat';

    final words = label
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .toList();

    return words.join(' ');
  }

  int get daysInActiveMonth {
    final m = activeMonth.value;
    return DateTime(m.year, m.month + 1, 0).day;
  }

  List<DateTime> get calendarDays {
    final m = activeMonth.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDays = daysInActiveMonth;
    return List.generate(
      totalDays,
      (i) => DateTime(m.year, m.month, i + 1),
    ).where((d) => !d.isAfter(today)).toList();
  }

  void changeMonth(DateTime picked) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final pickedMonth = DateTime(picked.year, picked.month);

    // Tolak bulan/tahun di masa depan
    if (pickedMonth.isAfter(currentMonth)) return;

    final newMonth = pickedMonth;
    activeMonth.value = newMonth;

    // Jika bulan yang dipilih adalah bulan ini, batas hari maksimal adalah hari ini
    final firstDay = DateTime(newMonth.year, newMonth.month, 1);
    selectedDate.value = firstDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (calendarScrollController.hasClients) {
        calendarScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Ambil records untuk tanggal yang dipilih sebagai [ScanRecord] agar
  /// history_view.dart tetap kompatibel
  List<ScanRecord> get recordsForSelectedDate {
    return _scanData[_fmt(selectedDate.value)] ?? [];
  }

  void selectDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    // Tolak tanggal di masa depan
    if (target.isAfter(today)) return;
    selectedDate.value = date;
  }

  bool isSelected(DateTime date) => _fmt(date) == _fmt(selectedDate.value);

  bool hasData(DateTime date) => _scanData.containsKey(_fmt(date));

  String dayName(DateTime date) {
    const days = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
    return days[date.weekday % 7];
  }

  String formattedSelectedDate() {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final d = selectedDate.value;
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String formattedActiveMonth() {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final m = activeMonth.value;
    return '${months[m.month - 1]} ${m.year}';
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void onClose() {
    calendarScrollController.dispose();
    super.onClose();
  }
}