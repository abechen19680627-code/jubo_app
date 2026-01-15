import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../members/providers/member_providers.dart';
import '../../orders/providers/order_providers.dart';

class MealStats {
  const MealStats({
    required this.title,
    required this.names,
  });

  final String title;
  final List<String> names;

  int get count => names.length;
}

class MealStatsData {
  const MealStatsData({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  final MealStats breakfast;
  final MealStats lunch;
  final MealStats dinner;
}

final mealStatsProvider = Provider<AsyncValue<MealStatsData>>((ref) {
  final membersAsync = ref.watch(membersStreamProvider);
  final ordersAsync = ref.watch(orderRecordsByDateProvider);

  if (membersAsync.isLoading || ordersAsync.isLoading) {
    return const AsyncLoading();
  }
  if (membersAsync.hasError) {
    return AsyncError(
      membersAsync.error!,
      membersAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (ordersAsync.hasError) {
    return AsyncError(
      ordersAsync.error!,
      ordersAsync.stackTrace ?? StackTrace.current,
    );
  }

  final members = membersAsync.value ?? [];
  final orders = ordersAsync.value ?? [];
  final orderMap = {
    for (final record in orders) record.memberId: record,
  };

  final breakfastNames = <String>[];
  final lunchNames = <String>[];
  final dinnerNames = <String>[];

  for (final member in members) {
    final record = orderMap[member.id];
    if (record == null) {
      continue;
    }
    if (record.breakfast) {
      breakfastNames.add(member.name);
    }
    if (record.lunch) {
      lunchNames.add(member.name);
    }
    if (record.dinner) {
      dinnerNames.add(member.name);
    }
  }

  return AsyncData(
    MealStatsData(
      breakfast: MealStats(title: '早餐', names: breakfastNames),
      lunch: MealStats(title: '午餐', names: lunchNames),
      dinner: MealStats(title: '晚餐', names: dinnerNames),
    ),
  );
});
