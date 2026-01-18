import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../orders/providers/order_providers.dart';
import 'providers/stats_providers.dart';

class StatsTab extends ConsumerStatefulWidget {
  const StatsTab({super.key});

  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab> {
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

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedOrderDateProvider);
    final dateLabel = formatOrderDate(date);
    final statsAsync = ref.watch(mealStatsProvider);
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
            child: statsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => _ErrorState(
                message: '載入統計失敗。',
                onRetry: () => ref.refresh(mealStatsProvider),
              ),
              data: (stats) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _MealCard(stats: stats.breakfast),
                    const SizedBox(height: 12),
                    _MealCard(stats: stats.lunch),
                    const SizedBox(height: 12),
                    _MealCard(stats: stats.dinner),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.stats});

  final MealStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final countStyle = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );
    final hasOrders = stats.count > 0;
    final namesText = hasOrders ? stats.names.join('、') : '尚無人點餐';

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stats.title, style: titleStyle),
            const SizedBox(height: 12),
            Text('${stats.count}', style: countStyle),
            const SizedBox(height: 8),
            Text(
              namesText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasOrders
                    ? theme.textTheme.bodyMedium?.color
                    : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
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
