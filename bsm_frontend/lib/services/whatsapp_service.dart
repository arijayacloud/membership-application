import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum WhatsAppApp {
  whatsapp,
  business,
}

class WhatsAppService {
  /// PUBLIC API
  static Future<void> openChat(
    String phone, {
    String? message,
    List<WhatsAppApp> priority = const [
      WhatsAppApp.whatsapp,
      WhatsAppApp.business,
    ],
    void Function(String step, Object? error)? onLog,
  }) async {
    final cleanPhone = _sanitizePhone(phone);
    final encodedMessage = Uri.encodeComponent(message ?? '');

    // ==========================
    // WEB
    // ==========================
    if (kIsWeb) {
      return _launch(
        _apiUrl(cleanPhone, encodedMessage),
        onLog,
        'web',
      );
    }

    // ==========================
    // ANDROID
    // ==========================
    if (Platform.isAndroid) {
      for (final app in priority) {
        final intent = _androidIntent(
          app,
          cleanPhone,
          encodedMessage,
        );

        final success = await _tryLaunch(intent, onLog, 'android-$app');
        if (success) return;
      }
    }

    // ==========================
    // IOS
    // ==========================
    if (Platform.isIOS) {
      return _launch(
        _apiUrl(cleanPhone, encodedMessage),
        onLog,
        'ios',
      );
    }

    // ==========================
    // FINAL FALLBACK
    // ==========================
    return _launch(
      _apiUrl(cleanPhone, encodedMessage),
      onLog,
      'fallback',
    );
  }

  // ======================================================
  // PRIVATE UTILITIES
  // ======================================================

  static String _sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static Uri _androidIntent(
    WhatsAppApp app,
    String phone,
    String message,
  ) {
    final package = app == WhatsAppApp.business
        ? 'com.whatsapp.w4b'
        : 'com.whatsapp';

    return Uri.parse(
      'intent://send?phone=$phone&text=$message'
      '#Intent;scheme=whatsapp;package=$package;end',
    );
  }

  static Uri _apiUrl(String phone, String message) {
    return Uri.parse(
      'https://api.whatsapp.com/send?phone=$phone&text=$message',
    );
  }

  static Future<bool> _tryLaunch(
    Uri uri,
    void Function(String step, Object? error)? onLog,
    String step,
  ) async {
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      onLog?.call(step, null);
      return true;
    } catch (e) {
      onLog?.call(step, e);
      return false;
    }
  }

  static Future<void> _launch(
    Uri uri,
    void Function(String step, Object? error)? onLog,
    String step,
  ) async {
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      onLog?.call(step, null);
    } catch (e) {
      onLog?.call(step, e);
    }
  }
}
