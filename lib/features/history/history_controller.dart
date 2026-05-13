import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final Rx<DateTime> activeMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  ).obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final ScrollController calendarScrollController = ScrollController();

  final Map<String, List<ScanRecord>> _dummyData = _buildDummyData();

  static Map<String, List<ScanRecord>> _buildDummyData() {
    final now = DateTime.now();
    return {
      _fmt(DateTime(now.year, now.month, 1)): [
        const ScanRecord(
          logId: '#3001',
          conditionName: 'Sehat',
          time: '07:30',
          accuracyPercent: 96,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.healthy,
        ),
      ],
      _fmt(DateTime(now.year, now.month, 3)): [
        const ScanRecord(
          logId: '#3100',
          conditionName: 'Bercak Daun Kuning',
          time: '09:15',
          accuracyPercent: 82,
          syncStatus: SyncStatus.local,
          healthStatus: HealthStatus.diseased,
        ),
        const ScanRecord(
          logId: '#3101',
          conditionName: 'Sehat',
          time: '14:00',
          accuracyPercent: 94,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.healthy,
        ),
      ],
      _fmt(now): [
        const ScanRecord(
          logId: '#3500',
          conditionName: 'Sehat',
          time: '09:15',
          accuracyPercent: 98,
          syncStatus: SyncStatus.local,
          healthStatus: HealthStatus.healthy,
        ),
      ],
      _fmt(now.subtract(const Duration(days: 2))): [
        const ScanRecord(
          logId: '#3461',
          conditionName: 'Bercak Daun Kuning',
          time: '10:00',
          accuracyPercent: 85,
          syncStatus: SyncStatus.local,
          healthStatus: HealthStatus.diseased,
        ),
        const ScanRecord(
          logId: '#3462',
          conditionName: 'Bercak Daun Kuning',
          time: '11:20',
          accuracyPercent: 80,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.diseased,
        ),
        const ScanRecord(
          logId: '#3460',
          conditionName: 'Sehat',
          time: '08:05',
          accuracyPercent: 97,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.healthy,
        ),
      ],
      _fmt(now.subtract(const Duration(days: 4))): [
        const ScanRecord(
          logId: '#2816',
          conditionName: 'Bercak Daun Kuning',
          time: '10:00',
          accuracyPercent: 85,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.diseased,
        ),
        const ScanRecord(
          logId: '#213',
          conditionName: 'Sehat',
          time: '13:41',
          accuracyPercent: 95,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.healthy,
        ),
      ],
      _fmt(DateTime(now.year, now.month - 1, 5)): [
        const ScanRecord(
          logId: '#2100',
          conditionName: 'Karat Daun',
          time: '08:45',
          accuracyPercent: 88,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.diseased,
        ),
      ],
      _fmt(DateTime(now.year, now.month - 1, 14)): [
        const ScanRecord(
          logId: '#2200',
          conditionName: 'Sehat',
          time: '10:30',
          accuracyPercent: 99,
          syncStatus: SyncStatus.synced,
          healthStatus: HealthStatus.healthy,
        ),
        const ScanRecord(
          logId: '#2201',
          conditionName: 'Bercak Daun Kuning',
          time: '15:00',
          accuracyPercent: 79,
          syncStatus: SyncStatus.local,
          healthStatus: HealthStatus.diseased,
        ),
      ],
    };
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
    return _dummyData[_fmt(selectedDate.value)] ?? [];
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  bool isSelected(DateTime date) => _fmt(date) == _fmt(selectedDate.value);

  bool hasData(DateTime date) => _dummyData.containsKey(_fmt(date));

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