import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../storage/local_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await ApiService.post("login", {
        "email": email,
        "password": password,
      }).timeout(const Duration(seconds: 15));

      final data = jsonDecode(res.body);

      debugPrint("STATUS: ${res.statusCode}");
      debugPrint("BODY: ${res.body}");

      if (res.statusCode == 200) {
        final token = data['access_token'] ?? data['token'];
        final user = data['user'];

        if (token == null || user == null) {
          return {"success": false, "message": "Format response tidak valid"};
        }

        await LocalStorage.saveToken(token);
        await LocalStorage.saveRole(user['role']);
        await LocalStorage.saveUserId(user['id']);

        return {"success": true, "role": user['role']};
      }

      return {"success": false, "message": data['message'] ?? "Login gagal"};
    } catch (e) {
      return {"success": false, "message": "Server tidak merespons"};
    }
  }

  static Future<Map> register(Map body) async {
    try {
      final res = await ApiService.post("register", body);

      Map data = {};
      try {
        data = jsonDecode(res.body);
      } catch (_) {}

      print("DEBUG REGISTER RESPONSE:");
      print(data);

      // ==============================
      // ✔ REGISTER SUKSES
      // ==============================
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {"success": true, "data": data};
      }

      // ==============================
      // ❌ ERROR VALIDASI
      // ==============================
      if (res.statusCode == 422) {
        return {
          "success": false,
          "errors": data['errors'] ?? {},
          "message": data['message'] ?? "Validasi gagal",
        };
      }

      // ==============================
      // ❌ ERROR LAIN
      // ==============================
      return {
        "success": false,
        "message": data['message'] ?? "Registrasi gagal",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server: $e",
      };
    }
  }

  static Future<void> logout() async {
    await LocalStorage.clear();
  }
}
