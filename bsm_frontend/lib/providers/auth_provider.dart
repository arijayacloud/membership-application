import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? role;
  Map? user;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    try {
      final res = await AuthService.login(email, password);

      if (res['success']) {
        role = res['data']['user']['role'];
        user = res['data']['user'];
        errorMessage = null;
        return true;
      } else {
        errorMessage = res['message'];
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email, // wajib
    required String phone,
    required String password,
    String role = "user",
    String adminKey = "",
  }) async {
    isLoading = true;
    notifyListeners();

    final body = {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "role": role,
    };

    if (role == "admin") {
      body["admin_secret"] = adminKey;
    }

    final res = await AuthService.register(body);

    isLoading = false;
    notifyListeners();

    if (res['success'] == true) {
      // backend return: { message, user }
      final userData = res['data']?['user'] ?? res['user'];

      if (userData != null) {
        user = userData;
        role = userData['role'];
        return true;
      }

      return false;
    }

    return false;
  }

  Future<void> logout(BuildContext context) async {
    _setLoading(true);

    // hapus token dan semua data lokal
    await AuthService.logout();

    // reset state AuthProvider
    role = null;
    user = null;
    errorMessage = null;

    _setLoading(false);
    notifyListeners();

    // redirect ke login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  /// internal handler
  void _setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }
}
