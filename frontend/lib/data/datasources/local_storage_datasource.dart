import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class LocalStorageDataSource {
  Future<UserModel?> getStoredUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearUser();
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  static const String _userSessionKey = 'flews_user_session_clean_v1';

  @override
  Future<UserModel?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userSessionKey);
      if (userString != null && userString.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(userString));
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }
}
