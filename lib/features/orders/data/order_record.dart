import 'package:hive/hive.dart';

const int orderRecordTypeId = 2;

class OrderRecord {
  OrderRecord({
    required this.date,
    required this.memberId,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  final String date;
  final String memberId;
  final bool breakfast;
  final bool lunch;
  final bool dinner;

  static String buildKey(String date, String memberId) {
    return '$date|$memberId';
  }
}

class OrderRecordAdapter extends TypeAdapter<OrderRecord> {
  @override
  int get typeId => orderRecordTypeId;

  @override
  OrderRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return OrderRecord(
      date: fields[0] as String,
      memberId: fields[1] as String,
      breakfast: fields[2] as bool,
      lunch: fields[3] as bool,
      dinner: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OrderRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.breakfast)
      ..writeByte(3)
      ..write(obj.lunch)
      ..writeByte(4)
      ..write(obj.dinner);
  }
}
