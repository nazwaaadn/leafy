// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionResultAdapter extends TypeAdapter<DetectionResult> {
  @override
  final int typeId = 0;

  @override
  DetectionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionResult(
      id: fields[0] as String,
      label: fields[1] as String,
      confidence: fields[2] as double,
      imagePath: fields[3] as String,
      detectedAt: fields[4] as DateTime,
      isSynced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.detectedAt)
      ..writeByte(5)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
