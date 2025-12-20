import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../storage/local_storage.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    try {
      final res = await ApiService.post("login", {
        "email": email,
        "password": password,
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final token = data['access_token'] ?? data['token'];
        final user = data['user'];

        if (token == null || user == null) return false;

        // Simpan ke local storage / shared preferences
        await LocalStorage.saveToken(token);
        await LocalStorage.saveRole(user['role']);
        await LocalStorage.saveUserId(user['id']);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      return false;
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
