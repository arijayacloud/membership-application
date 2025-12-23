class AppConfig {
  // 🟦 URL utama Laravel
  static const String baseUrl = "http://127.0.0.1:8000";

  // 🟦 Endpoint API
  static const String baseUrlApi = "$baseUrl/api";

  // 🟦 Akses file storage Laravel (banner promo, foto, dll)
  static const String baseUrlStorage = "$baseUrl/storage";
}
