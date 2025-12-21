import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../storage/local_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? role;
  Map? user;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    errorMessage = null;

    try {
      final res = await ApiService.post("login", {
        "email": email,
        "password": password,
      }).timeout(const Duration(seconds: 15));

      debugPrint("STATUS: ${res.statusCode}");
      debugPrint("BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final token = data['token'];
        final userData = data['user'];

        debugPrint("TOKEN: $token");

        if (token == null || userData == null) {
          errorMessage = "Response server tidak valid";
          return false;
        }

        await LocalStorage.saveToken(token);
        await LocalStorage.saveRole(userData['role']);
        await LocalStorage.saveUserId(userData['id']);

        role = userData['role'];
        user = userData;

        return true;
      }

      errorMessage = data['message'] ?? "Login gagal";
      return false;
    } on TimeoutException {
      errorMessage = "Koneksi timeout, periksa jaringan";
      return false;
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      errorMessage = "Terjadi kesalahan server";
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
