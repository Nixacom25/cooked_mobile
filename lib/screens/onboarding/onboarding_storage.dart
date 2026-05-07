import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const String _keyPrefix = 'onboarding_';
  static const String _keyStep = '${_keyPrefix}step';
  static const String _keyData = '${_keyPrefix}data';

  static Future<void> saveProgress(int step, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStep, step);
    
    // Clean data: convert Sets to Lists for JSON encoding
    final encodedData = data.map((key, value) {
      if (value is Set) return MapEntry(key, value.toList());
      return MapEntry(key, value);
    });
    
    await prefs.setString(_keyData, jsonEncode(encodedData));
  }

  static Future<Map<String, dynamic>?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final step = prefs.getInt(_keyStep);
    final dataString = prefs.getString(_keyData);

    if (step == null || dataString == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(dataString);
      data['step'] = step;
      return data;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStep);
    await prefs.remove(_keyData);
  }
}
