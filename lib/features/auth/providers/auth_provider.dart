import 'package:flutter/material.dart';
import '../../../data/local/shared_prefs_helper.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    checkAuthStatus();
  }

  // Kiểm tra trạng thái đăng nhập khi khởi động app
  Future<void> checkAuthStatus() async {
    _isAuthenticated = await SharedPrefsHelper.isLoggedIn();
    notifyListeners();
  }

  // Logic Đăng nhập
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Giả lập thời gian gọi API
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      // Đăng nhập thành công, lưu session với token giả định
      await SharedPrefsHelper.saveSession("mock_token_12345");
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logic Đăng ký
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Giả lập thời gian gọi API
    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      // Đăng ký thành công, tự động lưu phiên đăng nhập
      await SharedPrefsHelper.saveSession("mock_token_12345");
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logic Đăng xuất
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await SharedPrefsHelper.clearSession();
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }
}
