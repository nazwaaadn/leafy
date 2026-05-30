import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/scan_history_record.dart';
import '../../data/services/history_service.dart';
import '../../data/services/sync_service.dart';

// Re-export tipe agar history_view.dart tidak perlu berubah banyak
export '../../data/models/scan_history_record.dart';

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

  /// Konversi dari ScanHistoryRecord (Hive model)
  factory ScanRecord.fromHive(ScanHistoryRecord r) {
    return ScanRecord(
      logId: '#${r.id.substring(0, 6).toUpperCase()}',
      conditionName: r.conditionName,
      time: r.timeLabel,
      accuracyPercent: r.accuracyPercent.round(),
      syncStatus: r.isSynced ? SyncStatus.synced : SyncStatus.local,
      healthStatus: r.isHealthy ? HealthStatus.healthy : HealthStatus.diseased,
    );
  }
}

class HistoryController extends GetxController {
  final Rx<DateTime> activeMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final ScrollController calendarScrollController = ScrollController();

  final _historyService = HistoryService();

  /// Cache semua record dari Hive — direfresh setiap kali controller diaktifkan
  final RxList<ScanHistoryRecord> _allRecords = <ScanHistoryRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecords();
    // Saat SyncService berhasil sync ke MongoDB → refresh UI otomatis
    SyncService().onSyncComplete = refreshHistory;
  }

  /// Muat ulang dari Hive (dipanggil saat controller init & setelah save)
  void _loadRecords() {
    _allRecords.value = _historyService.getAll();
    pendingCount.value = _historyService.pendingCount;
  }

  /// Panggil ini setelah kembali dari halaman result agar list diperbarui
  void refreshHistory() => _loadRecords();

  /// Jumlah scan yang belum tersinkronisasi ke server (reaktif → Obx)
  final RxInt pendingCount = 0.obs;

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

  /// Ambil records untuk tanggal yang dipilih sebagai [ScanRecord] agar
  /// history_view.dart tetap kompatibel
  List<ScanRecord> get recordsForSelectedDate {
    final key = _fmt(selectedDate.value);
    return _allRecords
        .where((r) => r.dateKey == key)
        .map((r) => ScanRecord.fromHive(r))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  bool isSelected(DateTime date) => _fmt(date) == _fmt(selectedDate.value);

  bool hasData(DateTime date) {
    final key = _fmt(date);
    return _allRecords.any((r) => r.dateKey == key);
  }

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