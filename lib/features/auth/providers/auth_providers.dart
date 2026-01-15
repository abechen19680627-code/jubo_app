import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(sharedPreferencesProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<bool> {
  AuthController(this._repository) : super(_repository.getIsLoggedIn());

  static const _adminUsername = 'admin';
  static const _adminPassword = '1234';
  final AuthRepository _repository;

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final isValid =
        username == _adminUsername && password == _adminPassword;
    if (!isValid) {
      return '帳號或密碼錯誤，請再試一次。';
    }
    await _repository.setLoggedIn(true);
    state = true;
    return null;
  }

  Future<void> logout() async {
    await _repository.setLoggedIn(false);
    state = false;
  }
}
