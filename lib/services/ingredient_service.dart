import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';
import 'auth_service.dart';
import 'user_service.dart';

class IngredientService {
  static final IngredientService instance = IngredientService._();
  IngredientService._();

  Future<List<Map<String, dynamic>>> getSavedIngredients() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/saved'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<bool> saveIngredient(String name, {String icon = "🥕"}) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/saved'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'icon': icon,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> unsaveIngredient(String id) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/saved/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }
 
  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return [];
 
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/search?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
 
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getRecentIngredients() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/recent'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  // Local Persistence for Typed Ingredients
  static const String _recentIngBaseKey = 'recently_used_ingredients';

  Future<void> addToRecentTypedIngredient(String name) async {
    try {
      final user = UserService.instance.currentUserNotifier.value;
      final userId = user != null ? (user['id']?.toString() ?? 'guest') : 'guest';
      final key = '${_recentIngBaseKey}_$userId';
      
      final prefs = await SharedPreferences.getInstance();
      List<String> list = prefs.getStringList(key) ?? [];
      
      // Remove if exists
      list.removeWhere((item) => item.toLowerCase() == name.toLowerCase());
      
      // Add to start
      list.insert(0, name);
      
      // Limit to 10
      if (list.length > 10) list.removeLast();
      
      await prefs.setStringList(key, list);
    } catch (_) {}
  }

  Future<List<String>> getRecentTypedIngredients() async {
    try {
      final user = UserService.instance.currentUserNotifier.value;
      final userId = user != null ? (user['id']?.toString() ?? 'guest') : 'guest';
      final key = '${_recentIngBaseKey}_$userId';
      
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key) ?? [];
    } catch (_) {
      return [];
    }
  }
}
