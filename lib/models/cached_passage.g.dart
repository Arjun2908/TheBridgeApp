// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_passage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedPassageAdapter extends TypeAdapter<CachedPassage> {
  @override
  final int typeId = 2;

  @override
  CachedPassage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedPassage(
      key: fields[0] as String,
      passages: (fields[1] as List).cast<Passage>(),
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedPassage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.passages)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedPassageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
