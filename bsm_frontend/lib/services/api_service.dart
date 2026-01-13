import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/constants.dart';
import '../storage/local_storage.dart';
import 'package:http_parser/http_parser.dart';

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
          .post(uri, headers: baseHeaders(token), body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      return _error(e);
    }
  }

  // =====================================================
  // 🔵 GET (support query)
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
  static Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

      return await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      return _error(e);
    }
  }

  // ==========================
  // 🔥 PATCH (INI YANG KURANG)
  // ==========================
  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

      return await http
          .patch(uri, headers: baseHeaders(token), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
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
  // 📁 EXPORT EXCEL (Download + Buka File)
  // =====================================================
  static Future<void> exportExcelMembers() async {
    try {
      final res = await ApiService.get("admin/members/export");

      if (res.statusCode != 200) {
        throw Exception("Export gagal: ${res.statusCode}");
      }

      final bytes = res.bodyBytes;

      // folder download
      final dir = await getDownloadsDirectory();
      if (dir == null) throw Exception("Tidak bisa akses direktori download");

      final filePath = "${dir.path}/data-member.xlsx";
      final file = File(filePath);

      await file.writeAsBytes(bytes);

      print("📁 File berhasil disimpan: $filePath");

      // buka file otomatis
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception("Export error: $e");
    }
  }

  // =========================================================
  // MULTIPART POST (FILE - MOBILE)
  // =========================================================
  static Future<http.StreamedResponse> multipartPostBytes(
    String endpoint, {
    required Map<String, String> fields,
    required Uint8List bytes,
    required String filename,
    required String fieldName,
  }) async {
    final token = await LocalStorage.getToken();
    final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

    final req = http.MultipartRequest("POST", uri);
    req.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    req.fields.addAll(fields);

    // 🔍 DEBUG WAJIB
    debugPrint("📁 FILENAME: $filename");
    debugPrint("📦 BYTES LENGTH: ${bytes.length}");

    final ext = filename.split('.').last.toLowerCase();

    String mime;
    switch (ext) {
      case 'png':
        mime = 'png';
        break;
      case 'jpg':
      case 'jpeg':
        mime = 'jpeg';
        break;
      default:
        mime = 'jpeg';
    }

    debugPrint("🧪 EXT: $ext | MIME: image/$mime");

    req.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
        contentType: MediaType('image', mime),
      ),
    );

    return req.send();
  }

  static Future<http.StreamedResponse> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, File>? files, // ✅ OPSIONAL
  }) async {
    final token = await LocalStorage.getToken();
    final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

    final req = http.MultipartRequest("POST", uri);
    req.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    req.fields.addAll(fields);

    if (files != null && files.isNotEmpty) {
      for (var file in files.entries) {
        req.files.add(
          await http.MultipartFile.fromPath(file.key, file.value.path),
        );
      }
    }

    return req.send();
  }

  // =========================================================
  // MULTIPART PUT
  // =========================================================
  static Future<http.StreamedResponse> multipartPut(
    String endpoint, {
    required Map<String, String> fields,
    Map<String, File>? files,
  }) async {
    final token = await LocalStorage.getToken();
    final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

    final req = http.MultipartRequest("PUT", uri);
    req.headers.addAll(baseHeaders(token));

    fields.forEach((k, v) => req.fields[k] = v);

    if (files != null) {
      for (var f in files.entries) {
        req.files.add(await http.MultipartFile.fromPath(f.key, f.value.path));
      }
    }

    return req.send();
  }

  static Future<http.Response> getFile(String endpoint) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

      print("⏩ GET FILE $uri");

      return await http
          .get(
            uri,
            headers: {
              "Accept": "*/*",
              if (token != null) "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      return _error(e);
    }
  }

  static MediaType _getImageMediaType(String filename) {
    final ext = filename.split('.').last.toLowerCase();

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static Future<http.StreamedResponse> multipartPutBytes(
    String endpoint, {
    required Map<String, String> fields,
    required Uint8List bytes,
    required String filename,
    required String fieldName,
  }) async {
    final token = await LocalStorage.getToken();
    final uri = Uri.parse("${AppConfig.baseUrl}/api/$endpoint");

    final req = http.MultipartRequest("PUT", uri);
    req.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    req.fields.addAll(fields);

    req.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
        contentType: _getImageMediaType(filename),
      ),
    );

    return req.send();
  }

  static Future<Map<String, dynamic>> registerHomeService({
    required int memberId,
    required String serviceType,
    required String scheduleDate,
    required String scheduleTime,
    String? address,
    String? city,
    String? problemDescription,
    Uint8List? photoBytes,
    String? filename,
    File? photoFile,
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/home-service/request");

      debugPrint("⏩ POST $uri");
      debugPrint("MEMBER ID: $memberId");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // =========================
      // ✅ VALIDASI FRONTEND
      // =========================
      if (memberId <= 0 ||
          serviceType.trim().isEmpty ||
          scheduleDate.isEmpty ||
          scheduleTime.isEmpty) {
        return {"success": false, "message": "Data wajib tidak lengkap"};
      }

      // =========================
      // 📦 FIELDS
      // =========================
      request.fields.addAll({
        "member_id": memberId.toString(), // 🔥 PENTING
        "service_type": serviceType.trim(),
        "schedule_date": scheduleDate,
        "schedule_time": scheduleTime,
      });

      if (address?.isNotEmpty == true) {
        request.fields["address"] = address!.trim();
      }

      if (city?.isNotEmpty == true) {
        request.fields["city"] = city!.trim();
      }

      if (problemDescription?.isNotEmpty == true) {
        request.fields["problem_description"] = problemDescription!.trim();
      }

      // =========================
      // 📸 FILE UPLOAD
      // =========================
      if (photoBytes != null && filename != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'problem_photo',
            photoBytes,
            filename: filename,
            contentType: _getImageMediaType(filename),
          ),
        );
      } else if (photoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('problem_photo', photoFile.path),
        );
      }

      // =========================
      // 🚀 SEND REQUEST
      // =========================
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      debugPrint("STATUS CODE: ${res.statusCode}");
      debugPrint("RESPONSE BODY: ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        return {
          "success": decoded["success"] ?? true,
          "message": decoded["message"],
          "data": decoded["data"],
        };
      }

      if (res.statusCode == 422) {
        final decoded = jsonDecode(res.body);
        return {
          "success": false,
          "message": decoded["message"] ?? "Validasi gagal",
          "errors": decoded["errors"],
        };
      }

      if (res.statusCode == 401) {
        return {"success": false, "message": "Unauthenticated"};
      }

      return {
        "success": false,
        "message": "Server error ${res.statusCode}",
        "response": res.body,
      };
    } catch (e, s) {
      debugPrint("EXCEPTION: $e");
      debugPrint("STACKTRACE: $s");

      return {
        "success": false,
        "message": "Request failed",
        "error": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> createPromo({
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    Uint8List? bannerBytes, // WEB
    String? filename, // WEB
    File? bannerFile, // MOBILE
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/admin/promo");

      print("⏩ POST $uri");
      print("TOKEN: $token");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // =====================
      // FORM FIELDS
      // =====================
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;

      // =====================
      // FILE UPLOAD
      // =====================
      if (bannerBytes != null && filename != null) {
        // WEB
        final ext = filename.split('.').last.toLowerCase();

        String subtype = 'jpeg';
        if (ext == 'png') subtype = 'png';
        if (ext == 'gif') subtype = 'gif';
        if (ext == 'jpg') subtype = 'jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'banner',
            bannerBytes,
            filename: filename,
            contentType: MediaType('image', subtype),
          ),
        );
      } else if (bannerFile != null) {
        // MOBILE
        request.files.add(
          await http.MultipartFile.fromPath('banner', bannerFile.path),
        );
      }

      // =====================
      // SEND REQUEST
      // =====================
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      // =====================
      // RESPONSE HANDLING
      // =====================
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {
          "success": true,
          "data": res.body.isNotEmpty ? jsonDecode(res.body) : null,
        };
      } else if (res.statusCode == 422) {
        return {
          "success": false,
          "message": "Validation error",
          "errors": res.body.isNotEmpty ? jsonDecode(res.body) : null,
        };
      } else if (res.statusCode == 401) {
        return {"success": false, "message": "Unauthenticated"};
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode}",
          "response": res.body,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> updatePromo({
    required int id,
    required String title,
    required String description,
    required String startDate,
    required String endDate,
    Uint8List? bannerBytes, // WEB (optional)
    String? filename, // WEB (optional)
    File? bannerFile, // MOBILE (optional)
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse("${AppConfig.baseUrl}/api/admin/promo/$id");

      print("⏩ UPDATE PROMO $uri");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // =====================
      // METHOD SPOOFING (PUT)
      // =====================
      request.fields['_method'] = 'PUT';

      // =====================
      // FORM FIELDS
      // =====================
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;

      // =====================
      // FILE UPLOAD (OPTIONAL)
      // =====================
      if (bannerBytes != null && filename != null) {
        // WEB
        final ext = filename.split('.').last.toLowerCase();

        String subtype = 'jpeg';
        if (ext == 'png') subtype = 'png';
        if (ext == 'gif') subtype = 'gif';
        if (ext == 'jpg') subtype = 'jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'banner',
            bannerBytes,
            filename: filename,
            contentType: MediaType('image', subtype),
          ),
        );
      } else if (bannerFile != null) {
        // MOBILE
        request.files.add(
          await http.MultipartFile.fromPath('banner', bannerFile.path),
        );
      }
      // jika banner null → tidak dikirim (pakai gambar lama)

      // =====================
      // SEND REQUEST
      // =====================
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      // =====================
      // RESPONSE HANDLING
      // =====================
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {
          "success": true,
          "data": res.body.isNotEmpty ? jsonDecode(res.body) : null,
        };
      } else if (res.statusCode == 422) {
        return {
          "success": false,
          "message": "Validation error",
          "errors": res.body.isNotEmpty ? jsonDecode(res.body) : null,
        };
      } else if (res.statusCode == 401) {
        return {"success": false, "message": "Unauthenticated"};
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode}",
          "response": res.body,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  static Future<Map<String, dynamic>> finishWork({
    required int id,
    required String workNotes,
    Uint8List? photoBytes, // WEB (optional)
    String? filename, // WEB (optional)
    File? photoFile, // MOBILE (optional)
  }) async {
    try {
      final token = await LocalStorage.getToken();
      final uri = Uri.parse(
        "${AppConfig.baseUrl}/api/admin/home-services/$id/finish",
      );

      print("⏩ FINISH WORK $uri");

      final request = http.MultipartRequest("POST", uri);

      // =====================
      // HEADERS
      // =====================
      request.headers.addAll({
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      });

      // =====================
      // FORM FIELDS
      // =====================
      request.fields['work_notes'] = workNotes;

      // =====================
      // FILE UPLOAD (OPTIONAL)
      // =====================
      if (photoBytes != null && filename != null) {
        // 🌐 WEB
        final ext = filename.split('.').last.toLowerCase();

        String subtype = 'jpeg';
        if (ext == 'png') subtype = 'png';
        if (ext == 'gif') subtype = 'gif';
        if (ext == 'jpg') subtype = 'jpeg';

        request.files.add(
          http.MultipartFile.fromBytes(
            'completion_photo',
            photoBytes,
            filename: filename,
            contentType: MediaType('image', subtype),
          ),
        );
      } else if (photoFile != null) {
        // 📱 MOBILE
        request.files.add(
          await http.MultipartFile.fromPath('completion_photo', photoFile.path),
        );
      }
      // jika foto null → tidak dikirim

      // =====================
      // SEND REQUEST
      // =====================
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      // =====================
      // RESPONSE HANDLING
      // =====================
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {
          "success": true,
          "data": res.body.isNotEmpty ? jsonDecode(res.body) : null,
        };
      } else if (res.statusCode == 422) {
        return {
          "success": false,
          "message": "Validation error",
          "errors": res.body.isNotEmpty ? jsonDecode(res.body) : null,
        };
      } else if (res.statusCode == 401) {
        return {"success": false, "message": "Unauthenticated"};
      } else {
        return {
          "success": false,
          "message": "Server error: ${res.statusCode}",
          "response": res.body,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Request failed: $e"};
    }
  }

  static Map<String, String> imageHeaders() {
    final token = LocalStorage.getToken();

    return {
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static String imageUrl(String path) {
    return "${AppConfig.baseUrl}/api/image/$path";
  }

  static Future<http.Response> postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await LocalStorage.getToken();

    return http.post(
      Uri.parse("${AppConfig.baseUrl}/api/$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> putJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await LocalStorage.getToken();

    return http.put(
      Uri.parse("${AppConfig.baseUrl}/api/$endpoint"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  static Future<String?> getWhatsappNumber() async {
    final response = await ApiService.get("infos");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['status'] == true && json['data'] != null) {
        return json['data']['phone'];
      }
    }

    if (response.statusCode == 401) {
      debugPrint("❌ Unauthorized - token invalid atau expired");
    }

    return null;
  }

  // =====================================================
  // 🛑 Handler Error
  // =====================================================
  static http.Response _error(e) {
    return http.Response(jsonEncode({"message": "Error: $e"}), 500);
  }
}
