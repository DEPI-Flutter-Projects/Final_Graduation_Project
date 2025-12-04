import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _box = Hive.box('settings');
  final _key = 'themeMode';

  late final Rx<ThemeMode> _themeMode;

  ThemeService() {
    _themeMode = _loadThemeFromBox().obs;
  }

  ThemeMode get themeMode => _themeMode.value;

  ThemeMode _loadThemeFromBox() {
    final String? themeString = _box.get(_key);
    if (themeString == 'light') return ThemeMode.light;
    if (themeString == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  void _saveThemeToBox(ThemeMode mode) {
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    _box.put(_key, themeString);
  }

  void setTheme(ThemeMode mode) {
    Get.changeThemeMode(mode);
    _themeMode.value = mode;
    _saveThemeToBox(mode);
  }

  void initTheme() {
    Get.changeThemeMode(themeMode);
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode == ThemeMode.dark;
  }

  
  void switchTheme() {
    if (Get.isDarkMode) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}
