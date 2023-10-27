// import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;
  static const _keyImageCount = 'imageCount';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setImageCount(int imageCount) async =>
      await _preferences.setInt(_keyImageCount, imageCount);

  static int? getImageCount() => _preferences.getInt(_keyImageCount);
}
