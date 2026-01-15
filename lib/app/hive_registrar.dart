import 'package:hive/hive.dart';

import '../features/members/data/member.dart';
import '../features/orders/data/order_record.dart';

class HiveRegistrar {
  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(memberTypeId)) {
      Hive.registerAdapter(MemberAdapter());
    }
    if (!Hive.isAdapterRegistered(orderRecordTypeId)) {
      Hive.registerAdapter(OrderRecordAdapter());
    }
  }
}
