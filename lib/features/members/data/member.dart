import 'package:hive/hive.dart';

const int memberTypeId = 1;

class Member {
  Member({
    required this.id,
    required this.name,
    required this.birthday,
  });

  final String id;
  final String name;
  final DateTime birthday;

  int get age {
    final today = DateTime.now();
    var years = today.year - birthday.year;
    final hadBirthdayThisYear = today.month > birthday.month ||
        (today.month == birthday.month && today.day >= birthday.day);
    if (!hadBirthdayThisYear) {
      years -= 1;
    }
    return years;
  }

  Member copyWith({
    String? id,
    String? name,
    DateTime? birthday,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
    );
  }
}

class MemberAdapter extends TypeAdapter<Member> {
  @override
  int get typeId => memberTypeId;

  @override
  Member read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Member(
      id: fields[0] as String,
      name: fields[1] as String,
      birthday: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Member obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthday);
  }
}
