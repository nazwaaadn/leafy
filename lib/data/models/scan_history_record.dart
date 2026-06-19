import 'package:hive/hive.dart';

part 'scan_history_record.g.dart';

@HiveType(typeId: 1)
class ScanHistoryRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conditionName;

  @HiveField(2)
  final double accuracyPercent;

  @HiveField(3)
  final bool isHealthy;

  @HiveField(4)
  bool isSynced;

  @HiveField(5)
  final DateTime scannedAt;

  ScanHistoryRecord({
    required this.id,
    required this.conditionName,
    required this.accuracyPercent,
    required this.isHealthy,
    this.isSynced = false,
    required this.scannedAt,
  });

  String get dateKey {
    final d = scannedAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get timeLabel {
    final d = scannedAt;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
