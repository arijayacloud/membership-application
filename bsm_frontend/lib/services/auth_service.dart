import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../storage/local_storage.dart';

class AuthService {
  static Future<Map> login(String email, String password) async {
    try {
      final res = await ApiService.post("login", {
        "email": email,
        "password": password,
      });

      // --- Coba decode JSON, jika gagal buat Map kosong ---
      Map data = {};
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        return {
          "success": false,
          "message": "Response server tidak valid (bukan JSON)"
        };
      }

      print("DEBUG LOGIN RESPONSE:");
      print(data);

      switch (res.statusCode) {
        case 200:
          if (data['token'] != null) {
            await LocalStorage.saveToken(data['token']);
            return {"success": true, "data": data};
          }
          return {"success": false, "message": "Token tidak ditemukan"};

        case 401:
          return {
            "success": false,
            "message": data['message'] ?? "Email atau password salah"
          };

        case 422:
          return {
            "success": false,
            "errors": data['errors'] ?? {},
            "message": data['message'] ?? "Validasi gagal"
          };

        case 500:
          return {
            "success": false,
            "message": "Terjadi kesalahan pada server"
          };

        default:
          return {
            "success": false,
            "message": data['message'] ?? "Login gagal (${res.statusCode})"
          };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Tidak dapat terhubung ke server: $e",
      };
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
        "message": data['message'] ?? "Validasi gagal"
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
