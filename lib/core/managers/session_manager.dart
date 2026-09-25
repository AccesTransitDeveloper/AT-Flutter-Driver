import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../preferences/shared_preference_manager.dart';
import '../providers/app_providers.dart';

typedef SessionExpiredCallback = void Function();

class SessionManager {
  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();

  SessionManager._();

  SharedPreferenceManager? _sharedPref;
  SessionExpiredCallback? _onSessionExpired;

  void init(SharedPreferenceManager sharedPref) {
    _sharedPref = sharedPref;
  }

  void setSessionExpiredCallback(SessionExpiredCallback callback) {
    _onSessionExpired = callback;
  }

  void clearSessionExpiredCallback() {
    _onSessionExpired = null;
  }

  Future<void> handleTokenExpired() async {
    debugPrint('SessionManager: Token expired, logging out...');

    if (_sharedPref != null) {
      await _sharedPref!.signOut();
    }

    _onSessionExpired?.call();
  }

  bool isTokenExpired(int statusCode, String? message) {
    return statusCode == 409 &&
        message?.toLowerCase().contains('invalid token') == true;
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  final sharedPrefAsync = ref.watch(sharedPreferenceManagerProvider);

  sharedPrefAsync.whenData((sharedPref) {
    SessionManager.instance.init(sharedPref);
  });

  return SessionManager.instance;
});
