import 'package:hive/hive.dart';

import 'member.dart';

class MemberRepository {
  static const boxName = 'members';

  Future<Box<Member>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Member>(boxName);
    }
    return Hive.openBox<Member>(boxName);
  }

  Stream<List<Member>> watchMembers() async* {
    final box = await _openBox();
    yield box.values.toList();
    await for (final _ in box.watch()) {
      yield box.values.toList();
    }
  }

  Future<Member?> getMemberById(String id) async {
    final box = await _openBox();
    return box.get(id);
  }

  Future<void> upsertMember(Member member) async {
    final box = await _openBox();
    await box.put(member.id, member);
  }

  Future<void> deleteMember(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
