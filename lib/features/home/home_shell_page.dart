import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/providers/auth_providers.dart';
import '../members/members_tab.dart';
import '../orders/order_tab.dart';
import '../stats/stats_tab.dart';

final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  static const _titles = <String>['成員', '點餐', '統計'];
  static const _tabs = <Widget>[
    MembersTab(),
    OrderTab(),
    StatsTab(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[index]),
        actions: [
          IconButton(
            tooltip: '登出',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('確認登出？'),
                    content: const Text('將返回登入頁。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('登出'),
                      ),
                    ],
                  );
                },
              );
              if (shouldLogout != true || !context.mounted) {
                return;
              }
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) {
                return;
              }
              context.go('/login');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 380),
        selectedIndex: index,
        onDestinationSelected: (value) =>
            ref.read(homeTabIndexProvider.notifier).state = value,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: '成員',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: '點餐',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: '統計',
          ),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton(
              tooltip: '新增成員',
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await context.push<bool>('/member/add');
                if (!context.mounted || result != true) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已新增成員。')),
                );
              },
            )
          : null,
    );
  }
}
