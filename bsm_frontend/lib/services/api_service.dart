import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../storage/local_storage.dart';

class ApiService {
  // =====================================================
  // 🔹 HEADER
  // =====================================================
  static Map<String, String> baseHeaders(String? token) {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // =====================================================
  // 🔵 POST
  // =====================================================
  static Future<http.Response> post(String endpoint, Map body) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

      print("⏩ POST $uri");
      print("TOKEN: $token");

      return await http
          .post(
            uri,
            headers: {
              ...baseHeaders(token),
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      return _error(e);
    }
  }

  // =====================================================
  // 🔵 GET (dengan query parameter support)
  // =====================================================
  static Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final token = await LocalStorage.getToken();

      final uri = Uri.parse(
        "${AppConfig.baseUrl}/api/$endpoint",
      ).replace(queryParameters: query);

      print("⏩ GET $uri");
      print("TOKEN: $token");

      return await http
          .get(uri, headers: baseHeaders(token))
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      return _error(e);
    }
  }

  // =====================================================
  // 🔵 PUT
  // =====================================================
  static Future<http.Response> put(String endpoint, Map body) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

      return await http.put(
        uri,
        headers: {...baseHeaders(token), "Content-Type": "application/json"},
        body: jsonEncode(body),
      );
    } catch (e) {
      return _error(e);
    }
  }

  // =====================================================
  // 🔴 DELETE
  // =====================================================
  static Future<http.Response> delete(String endpoint) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

      return await http.delete(uri, headers: baseHeaders(token));
    } catch (e) {
      return _error(e);
    }
  }

  // =====================================================
  // 🛑 Handler
  // =====================================================
  static http.Response _error(e) {
    return http.Response(jsonEncode({"message": "Error: $e"}), 500);
  }
}
