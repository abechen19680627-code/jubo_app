import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/order_record.dart';
import '../data/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

DateTime normalizeOrderDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String formatOrderDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

final selectedOrderDateProvider = StateProvider<DateTime>((ref) {
  return normalizeOrderDate(DateTime.now());
});

final selectedOrderDateKeyProvider = Provider<String>((ref) {
  final date = ref.watch(selectedOrderDateProvider);
  return formatOrderDate(date);
});

final orderRecordsByDateProvider =
    StreamProvider<List<OrderRecord>>((ref) {
  final dateKey = ref.watch(selectedOrderDateKeyProvider);
  return ref.watch(orderRepositoryProvider).watchOrdersByDate(dateKey);
});

final orderActionsProvider = Provider<OrderActions>((ref) {
  return OrderActions(ref.watch(orderRepositoryProvider));
});

class OrderActions {
  OrderActions(this._repository);

  final OrderRepository _repository;

  Future<void> updateOrder({
    required DateTime date,
    required String memberId,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  }) async {
    final record = OrderRecord(
      date: formatOrderDate(date),
      memberId: memberId,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );
    await _repository.upsertOrder(record);
  }
}
