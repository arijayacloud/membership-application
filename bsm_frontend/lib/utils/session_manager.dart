import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _lastActiveKey = 'last_active_time';

  /// ⏳ batas idle: 1 jam
  static const Duration sessionTimeout = Duration(hours: 1);

  // simpan waktu terakhir aktif
  static Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastActiveKey,
      DateTime.now().toIso8601String(),
    );
  }

  // ambil waktu terakhir aktif
  static Future<DateTime?> getLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastActiveKey);
    return value != null ? DateTime.tryParse(value) : null;
  }

  // ✅ CEK SESSION EXPIRED
  static Future<bool> isSessionExpired() async {
    final lastActive = await getLastActive();

    // belum pernah aktif → anggap expired
    if (lastActive == null) return true;

    final diff = DateTime.now().difference(lastActive);
    return diff > sessionTimeout;
  }

  // hapus session
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActiveKey);
  }
}
