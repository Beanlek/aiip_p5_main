// import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class ImageCountPreferences {
  static late SharedPreferences _preferences;
  static const _keyImageCount = 'imageCount';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setImageCount(int imageCount) async =>
      await _preferences.setInt(_keyImageCount, imageCount);

  static int? getImageCount() => _preferences.getInt(_keyImageCount);
}

class UserPreferences {
  static late SharedPreferences _preferences;
  static const _keyJson = 'van_users';
  static const _keyUser = 'user';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setJson(String json) async =>
      await _preferences.setString(_keyJson, json);

  static String? getJson() => _preferences.getString(_keyJson);

  static Future setUserId(String uuid) async =>
      await _preferences.setString(_keyUser, uuid);

  static String? getUserId() => _preferences.getString(_keyUser);
}
