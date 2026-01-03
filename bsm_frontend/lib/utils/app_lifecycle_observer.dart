import 'package:flutter/widgets.dart';
import '../utils/session_manager.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onSessionExpired;

  AppLifecycleObserver({required this.onSessionExpired});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (await SessionManager.isSessionExpired()) {
        onSessionExpired();
      } else {
        SessionManager.updateLastActive();
      }
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      SessionManager.updateLastActive();
    }
  }
}
