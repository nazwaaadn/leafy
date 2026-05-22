import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:leafy_app/data/models/detection_result.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';
import 'package:leafy_app/data/services/mongo_service.dart';
import 'package:leafy_app/data/services/session_service.dart';

enum SyncStatus { local, synced }

enum HealthStatus { healthy, diseased }

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

  @override
  void onInit() {
    super.onInit();
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
    }
  }

  Future<void> _loadFromMongo() async {
    final grouped = await _mongo.getDetectionsGroupedByDate(
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
      if (!Hive.isBoxOpen('detections')) {
        _scanData.value = {};
        return;
      }

      final box = Hive.box<DetectionResult>('detections');
      final Map<String, List<ScanRecord>> result = {};

      for (final item in box.values) {
        final dateKey = _fmt(item.detectedAt.toLocal());
        final record = _detectionResultToScanRecord(item);
        result.putIfAbsent(dateKey, () => []).add(record);
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
    final label = (doc['label'] ?? '').toString();
    final confidence = (doc['confidence'] ?? 0.0) as num;
    final rawDate = doc['detectedAt']?.toString() ?? '';
    final dt = DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now();
    final isSynced = doc['isSynced'] == true;

    return ScanRecord(
      logId: _shortId(doc['_id']?.toString() ?? ''),
      conditionName: _labelToConditionName(label),
      time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      accuracyPercent: (confidence * 100).round().clamp(0, 100),
      syncStatus: isSynced ? SyncStatus.synced : SyncStatus.local,
      healthStatus: label.toLowerCase().contains('healthy')
          ? HealthStatus.healthy
          : HealthStatus.diseased,
    );
  }

  ScanRecord _detectionResultToScanRecord(DetectionResult item) {
    final dt = item.detectedAt.toLocal();
    return ScanRecord(
      logId: _shortId(item.id),
      conditionName: _labelToConditionName(item.label),
      time: '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}',
      accuracyPercent: (item.confidence * 100).round().clamp(0, 100),
      syncStatus: item.isSynced ? SyncStatus.synced : SyncStatus.local,
      healthStatus: item.label.toLowerCase().contains('healthy')
          ? HealthStatus.healthy
          : HealthStatus.diseased,
    );
  }

  String _shortId(String id) {
    if (id.isEmpty) return '#???';
    final clean = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return '#${clean.substring(0, clean.length.clamp(0, 6)).toUpperCase()}';
  }

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
    return List.generate(
      daysInActiveMonth,
      (i) => DateTime(m.year, m.month, i + 1),
    );
  }

  void changeMonth(DateTime picked) {
    final newMonth = DateTime(picked.year, picked.month);
    activeMonth.value = newMonth;

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

  List<ScanRecord> get recordsForSelectedDate {
    return _scanData[_fmt(selectedDate.value)] ?? [];
  }

  void selectDate(DateTime date) {
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