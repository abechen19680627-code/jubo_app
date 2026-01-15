import 'package:hive/hive.dart';

import 'order_record.dart';

class OrderRepository {
  static const boxName = 'orders';

  Future<Box<OrderRecord>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<OrderRecord>(boxName);
    }
    return Hive.openBox<OrderRecord>(boxName);
  }

  Stream<List<OrderRecord>> watchOrdersByDate(String date) async* {
    final box = await _openBox();
    List<OrderRecord> filterByDate() {
      return box.values.where((record) => record.date == date).toList();
    }

    yield filterByDate();
    await for (final _ in box.watch()) {
      yield filterByDate();
    }
  }

  Future<OrderRecord?> getOrder(String date, String memberId) async {
    final box = await _openBox();
    final key = OrderRecord.buildKey(date, memberId);
    return box.get(key);
  }

  Future<void> upsertOrder(OrderRecord record) async {
    final box = await _openBox();
    final key = OrderRecord.buildKey(record.date, record.memberId);
    await box.put(key, record);
  }

  Future<void> deleteByMemberId(String memberId) async {
    final box = await _openBox();
    final keysToDelete = <dynamic>[];
    for (var i = 0; i < box.length; i++) {
      final record = box.getAt(i);
      if (record != null && record.memberId == memberId) {
        keysToDelete.add(box.keyAt(i));
      }
    }
    if (keysToDelete.isEmpty) {
      return;
    }
    await box.deleteAll(keysToDelete);
  }
}
