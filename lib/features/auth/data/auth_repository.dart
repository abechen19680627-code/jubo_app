import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  AuthRepository(this._prefs);

  static const _isLoggedInKey = 'isLoggedIn';
  final SharedPreferences _prefs;

  bool getIsLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }
}
