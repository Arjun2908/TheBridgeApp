// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PassageAdapter extends TypeAdapter<Passage> {
  @override
  final int typeId = 1;

  @override
  Passage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Passage(
      text: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Passage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
