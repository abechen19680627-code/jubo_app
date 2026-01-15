import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/home/home_shell_page.dart';
import '../features/login/login_page.dart';
import '../features/members/member_form_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeShellPage(),
      ),
      GoRoute(
        path: '/member/add',
        builder: (context, state) => const MemberFormPage(),
      ),
      GoRoute(
        path: '/member/edit/:id',
        builder: (context, state) {
          return MemberFormPage(memberId: state.pathParameters['id']!);
        },
      ),
    ],
  );
});
