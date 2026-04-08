import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _key = 'themeMode';


  final _themeModeStr = 'system'.obs;

  String get currentThemeModeStr => _themeModeStr.value;

  /// Map string to ThemeMode
  ThemeMode get theme {
    switch (_themeModeStr.value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeModeStr.value = prefs.getString(_key) ?? 'system';
    Get.changeThemeMode(theme);
  }

  /// Update and save theme
  Future<void> setThemeMode(String mode) async {
    _themeModeStr.value = mode;
    Get.changeThemeMode(theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode);
  }

  /// Helper for toggle (switches between light and dark, or moves away from system)
  bool get isDarkMode => _themeModeStr.value == 'dark' ||
      (_themeModeStr.value == 'system' && Get.isPlatformDarkMode);

  void toggleTheme() {
    if (_themeModeStr.value == 'dark') {
      setThemeMode('light');
    } else {
      setThemeMode('dark');
    }
  }

  // Alias for backward compatibility if needed
  void switchTheme() => toggleTheme();
}