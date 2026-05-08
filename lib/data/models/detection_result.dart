import 'package:hive/hive.dart';

part 'detection_result.g.dart';

@HiveType(typeId: 0)
class DetectionResult extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String label;
  @HiveField(2)
  final double confidence;
  @HiveField(3)
  final String imagePath;
  @HiveField(4)
  final DateTime detectedAt;
  @HiveField(5)
  bool isSynced;

  DetectionResult({
    required this.id,
    required this.label,
    required this.confidence,
    required this.imagePath,
    required this.detectedAt,
    this.isSynced = false,
  });
}
