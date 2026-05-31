// GENERATED CODE - DO NOT MODIFY BY HAND
// (manually written adapter — matches typeId: 1)

part of 'scan_history_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanHistoryRecordAdapter extends TypeAdapter<ScanHistoryRecord> {
  @override
  final int typeId = 1;

  @override
  ScanHistoryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanHistoryRecord(
      id: fields[0] as String,
      conditionName: fields[1] as String,
      accuracyPercent: (fields[2] as num).toDouble(),
      isHealthy: (fields[3] as bool?) ??
          ((fields[1] as String).toLowerCase().contains('sehat') ||
           (fields[1] as String).toLowerCase().contains('healthy')),
      isSynced: (fields[4] as bool?) ?? false,
      scannedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ScanHistoryRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conditionName)
      ..writeByte(2)
      ..write(obj.accuracyPercent)
      ..writeByte(3)
      ..write(obj.isHealthy)
      ..writeByte(4)
      ..write(obj.isSynced)
      ..writeByte(5)
      ..write(obj.scannedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanHistoryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
