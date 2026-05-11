import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const String _userKey = 'voltarisyn_user';
  static const String _accountTypeKey = 'voltarisyn_account_type';
  static const String _accountLockedKey = 'voltarisyn_account_locked';
  static const String _isLoggedInKey = 'voltarisyn_logged_in';
  static const String _notificationsKey = 'voltarisyn_notifications';
  static const String _autoPowerCutKey = 'voltarisyn_auto_power_cut';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) {
      return UserModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<void> saveAccountType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountTypeKey, type);
  }

  Future<String> getAccountType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accountTypeKey) ?? 'home';
  }

  Future<void> setAccountLocked(bool locked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountLockedKey, locked);
  }

  Future<bool> isAccountLocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_accountLockedKey) ?? false;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> saveAutoPowerCut(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPowerCutKey, enabled);
  }

  Future<bool> getAutoPowerCut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPowerCutKey) ?? true;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
