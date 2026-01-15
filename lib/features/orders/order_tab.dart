import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../members/data/member.dart';
import '../members/providers/member_providers.dart';
import 'data/order_record.dart';
import 'providers/order_providers.dart';

class OrderTab extends ConsumerStatefulWidget {
  const OrderTab({super.key});

  @override
  ConsumerState<OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends ConsumerState<OrderTab> {
  Future<void> _pickDate() async {
    final current = ref.read(selectedOrderDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    ref.read(selectedOrderDateProvider.notifier).state =
        normalizeOrderDate(picked);
  }

  Future<void> _updateOrder({
    required DateTime date,
    required Member member,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  }) async {
    try {
      await ref.read(orderActionsProvider).updateOrder(
            date: date,
            memberId: member.id,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新點餐失敗。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedOrderDateProvider);
    final membersAsync = ref.watch(membersStreamProvider);
    final ordersAsync = ref.watch(orderRecordsByDateProvider);
    final dateLabel = formatOrderDate(selectedDate);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('日期'),
                subtitle: Text(dateLabel),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
            ),
          ),
          Expanded(
            child: _buildContent(
              context,
              membersAsync: membersAsync,
              ordersAsync: ordersAsync,
              selectedDate: selectedDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required AsyncValue<List<Member>> membersAsync,
    required AsyncValue<List<OrderRecord>> ordersAsync,
    required DateTime selectedDate,
  }) {
    if (membersAsync.isLoading || ordersAsync.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (membersAsync.hasError) {
      return _ErrorState(
        message: '載入成員失敗。',
        onRetry: () => ref.refresh(membersStreamProvider),
      );
    }
    if (ordersAsync.hasError) {
      return _ErrorState(
        message: '載入點餐資料失敗。',
        onRetry: () => ref.refresh(orderRecordsByDateProvider),
      );
    }
    final members = membersAsync.value ?? [];
    if (members.isEmpty) {
      return const _EmptyState(
        message: '尚無成員，請先新增成員。',
      );
    }
    final orders = ordersAsync.value ?? [];
    final orderMap = {
      for (final record in orders) record.memberId: record,
    };

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: members.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = members[index];
        final record = orderMap[member.id];
        return _OrderRow(
          member: member,
          record: record,
          onChanged: (breakfast, lunch, dinner) {
            _updateOrder(
              date: selectedDate,
              member: member,
              breakfast: breakfast,
              lunch: lunch,
              dinner: dinner,
            );
          },
        );
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.member,
    required this.record,
    required this.onChanged,
  });

  final Member member;
  final OrderRecord? record;
  final void Function(bool breakfast, bool lunch, bool dinner) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakfast = record?.breakfast ?? false;
    final lunch = record?.lunch ?? false;
    final dinner = record?.dinner ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _MealToggle(
                  label: '早餐',
                  value: breakfast,
                  onChanged: (value) {
                    onChanged(value, lunch, dinner);
                  },
                ),
                _MealToggle(
                  label: '午餐',
                  value: lunch,
                  onChanged: (value) {
                    onChanged(breakfast, value, dinner);
                  },
                ),
                _MealToggle(
                  label: '晚餐',
                  value: dinner,
                  onChanged: (value) {
                    onChanged(breakfast, lunch, value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MealToggle extends StatelessWidget {
  const _MealToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (checked) => onChanged(checked ?? false),
        ),
        Text(label),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('重試'),
          ),
        ],
      ),
    );
  }
}
