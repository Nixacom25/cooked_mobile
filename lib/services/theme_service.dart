import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The manual light/dark toggle is a debug-only tool for verifying the dark
/// theme during development. Production builds always follow the system
/// theme - there's no in-app override, so this never reads or writes the
/// persisted preference outside kDebugMode.
class ThemeService {
  ThemeService._privateConstructor();
  static final ThemeService instance = ThemeService._privateConstructor();

  static const String _prefsKey = 'app_theme_mode';

  final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  Future<void> init() async {
    if (!kDebugMode) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      themeModeNotifier.value = _fromKey(stored) ?? ThemeMode.system;
    } catch (_) {
      // Keep the ThemeMode.system default if prefs can't be read.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (!kDebugMode) return;
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _toKey(mode));
    } catch (_) {}
  }

  String _toKey(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode? _fromKey(String? key) {
    switch (key) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
