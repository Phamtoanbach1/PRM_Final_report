import 'package:flutter/material.dart';

import '../../../data/local/shared_prefs_helper.dart';
import '../domain/user_role.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    checkAuthStatus();
  }

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _email;
  String? _name;
  UserRole _role = UserRole.user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  /// Email đang đăng nhập (để hiển thị hồ sơ & phân tách dữ liệu booking).
  String? get displayEmail => _email;

  /// Tên hiển thị (đăng ký), có thể null nếu chỉ đăng nhập.
  String? get displayName => _name;
  UserRole get role => _role;
  bool get isAdmin => _role == UserRole.admin;
  bool get isShopOwner => _role == UserRole.shopOwner;
  bool get canAccessAdmin => isAdmin || isShopOwner;

  Future<void> checkAuthStatus() async {
    _isAuthenticated = await SharedPrefsHelper.isLoggedIn();
    _email = await SharedPrefsHelper.getUserEmail();
    _name = await SharedPrefsHelper.getUserName();
    _role = UserRole.fromStorage(await SharedPrefsHelper.getUserRole());
    notifyListeners();
  }

  UserRole _resolveRoleByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized == 'admin@hancruise.local') return UserRole.admin;
    if ((normalized.startsWith('owner') || normalized.startsWith('shop'))
        && normalized.endsWith('@hancruise.local')) {
      return UserRole.shopOwner;
    }
    return UserRole.user;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (email.trim().isNotEmpty && password.isNotEmpty) {
      final resolvedRole = _resolveRoleByEmail(email);
      await SharedPrefsHelper.saveSession(
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        role: resolvedRole.storageValue,
      );
      _email = email.trim();
      _role = resolvedRole;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (name.trim().isNotEmpty && email.trim().isNotEmpty && password.isNotEmpty) {
      await SharedPrefsHelper.saveSession(
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        name: name.trim(),
        role: UserRole.user.storageValue,
      );
      _email = email.trim();
      _name = name.trim();
      _role = UserRole.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await SharedPrefsHelper.clearSession();
    _isAuthenticated = false;
    _email = null;
    _name = null;
    _role = UserRole.user;
    _isLoading = false;
    notifyListeners();
  }
}
