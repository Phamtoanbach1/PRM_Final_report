import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'token';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _favoriteBoatsKeyBase = 'favorite_boats_v1';

  /// Lưu phiên đăng nhập + thông tin hiển thị (demo, không gọi API thật).
  static Future<void> saveSession({
    required String token,
    String? email,
    String? name,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_tokenKey, token);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_emailKey, email.trim());
    }
    if (name != null && name.isNotEmpty) {
      await prefs.setString(_nameKey, name.trim());
    } else {
      await prefs.remove(_nameKey);
    }
    if (role != null && role.isNotEmpty) {
      await prefs.setString(_roleKey, role);
    } else {
      await prefs.setString(_roleKey, 'user');
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String> _favoriteBoatsKey() async {
    final email = await getUserEmail();
    if (email == null || email.isEmpty) return _favoriteBoatsKeyBase;
    return '${_favoriteBoatsKeyBase}_${email.hashCode}';
  }

  static Future<List<String>> getFavoriteBoatIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _favoriteBoatsKey();
    return prefs.getStringList(key) ?? <String>[];
  }

  static Future<void> saveFavoriteBoatIds(List<String> boatIds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _favoriteBoatsKey();
    await prefs.setStringList(key, boatIds);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_roleKey);
  }
}
