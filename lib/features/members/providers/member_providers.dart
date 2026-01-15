import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../orders/data/order_repository.dart';
import '../../orders/providers/order_providers.dart';
import '../data/member.dart';
import '../data/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final membersStreamProvider = StreamProvider<List<Member>>((ref) {
  return ref.watch(memberRepositoryProvider).watchMembers();
});

final memberByIdProvider =
    FutureProvider.family<Member?, String>((ref, memberId) {
  return ref.watch(memberRepositoryProvider).getMemberById(memberId);
});

final memberSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredMembersProvider =
    Provider<AsyncValue<List<Member>>>((ref) {
  final membersAsync = ref.watch(membersStreamProvider);
  final query = ref.watch(memberSearchQueryProvider).trim().toLowerCase();
  return membersAsync.whenData((members) {
    if (query.isEmpty) {
      return members;
    }
    return members
        .where((member) => member.name.toLowerCase().contains(query))
        .toList();
  });
});

final memberActionsProvider = Provider<MemberActions>((ref) {
  return MemberActions(
    memberRepository: ref.watch(memberRepositoryProvider),
    orderRepository: ref.watch(orderRepositoryProvider),
    uuid: ref.watch(uuidProvider),
  );
});

class MemberActions {
  MemberActions({
    required MemberRepository memberRepository,
    required this.orderRepository,
    required this.uuid,
  }) : _memberRepository = memberRepository;

  final MemberRepository _memberRepository;
  final OrderRepository orderRepository;
  final Uuid uuid;

  Future<void> saveMember({
    required String name,
    required DateTime birthday,
    String? id,
  }) async {
    final memberId = id ?? uuid.v4();
    final member = Member(
      id: memberId,
      name: name,
      birthday: birthday,
    );
    await _memberRepository.upsertMember(member);
  }

  Future<void> deleteMember(String id) async {
    await orderRepository.deleteByMemberId(id);
    await _memberRepository.deleteMember(id);
  }
}
