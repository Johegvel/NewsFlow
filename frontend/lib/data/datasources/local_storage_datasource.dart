import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_session_model.dart';

abstract class LocalStorageDataSource {
  Future<AuthSessionModel?> getStoredSession();
  Future<void> saveSession(AuthSessionModel session);
  Future<void> clearSession();
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  static const String _sessionKey = 'flews_auth_session_v2';
  static const String _legacyUserSessionKey = 'flews_user_session_clean_v1';

  @override
  Future<AuthSessionModel?> getStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionString = prefs.getString(_sessionKey);
      if (sessionString != null && sessionString.isNotEmpty) {
        final decoded = jsonDecode(sessionString);
        if (decoded is Map<String, dynamic>) {
          return AuthSessionModel.fromJson(decoded);
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    await prefs.remove(_legacyUserSessionKey);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_legacyUserSessionKey);
  }
}
