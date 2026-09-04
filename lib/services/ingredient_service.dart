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
 
  static const List<Map<String, String>> _commonIngredients = [
    {'name': 'Garlic', 'icon': '🧄'},
    {'name': 'Onion', 'icon': '🧅'},
    {'name': 'Tomato', 'icon': '🍅'},
    {'name': 'Cheese', 'icon': '🧀'},
    {'name': 'Milk', 'icon': '🥛'},
    {'name': 'Egg', 'icon': '🥚'},
    {'name': 'Chicken', 'icon': '🍗'},
    {'name': 'Beef', 'icon': '🥩'},
    {'name': 'Flour', 'icon': '🌾'},
    {'name': 'Rice', 'icon': '🍚'},
    {'name': 'Noodles', 'icon': '🍜'},
    {'name': 'Nori', 'icon': '🍙'},
    {'name': 'Nutmeg', 'icon': '🧆'},
    {'name': 'Navy Beans', 'icon': '🫘'},
    {'name': 'Napa Cabbage', 'icon': '🥬'},
    {'name': 'Butter', 'icon': '🧈'},
    {'name': 'Sugar', 'icon': '🍬'},
    {'name': 'Salt', 'icon': '🧂'},
    {'name': 'Pepper', 'icon': '🌶️'},
    {'name': 'Olive Oil', 'icon': '🫒'},
    {'name': 'Bacon', 'icon': '🥓'},
    {'name': 'Potato', 'icon': '🥔'},
    {'name': 'Carrot', 'icon': '🥕'},
    {'name': 'Spinach', 'icon': '🥬'},
    {'name': 'Mushroom', 'icon': '🍄'},
    {'name': 'Avocado', 'icon': '🥑'},
    {'name': 'Lemon', 'icon': '🍋'},
    {'name': 'Lime', 'icon': '🟢'},
    {'name': 'Honey', 'icon': '🍯'},
    {'name': 'Bread', 'icon': '🍞'},
    {'name': 'Pasta', 'icon': '🍝'},
    {'name': 'Pork', 'icon': '🥩'},
    {'name': 'Salmon', 'icon': '🐟'},
    {'name': 'Shrimp', 'icon': '🦐'},
    {'name': 'Soy Sauce', 'icon': '🏺'},
    {'name': 'Apple', 'icon': '🍎'},
    {'name': 'Banana', 'icon': '🍌'},
  ];

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    List<Map<String, dynamic>> rawResults = [];

    try {
      final token = await AuthService.instance.getToken();
      if (token != null) {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/ingredients/search?q=${Uri.encodeComponent(cleanQuery)}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          rawResults = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}

    // Combine with local common ingredients matching query
    final qLower = cleanQuery.toLowerCase();
    final Map<String, Map<String, dynamic>> uniqueMap = {};

    for (var r in rawResults) {
      final name = (r['name'] ?? '').toString();
      if (name.isNotEmpty) {
        uniqueMap[name.toLowerCase()] = r;
      }
    }

    // Add recent typed ingredients matching query
    final recentTyped = await getRecentTypedIngredients();
    for (var name in recentTyped) {
      if (name.toLowerCase().contains(qLower) && !uniqueMap.containsKey(name.toLowerCase())) {
        uniqueMap[name.toLowerCase()] = {'name': name, 'icon': '🥕'};
      }
    }

    // Add common ingredients matching query
    for (var item in _commonIngredients) {
      final name = item['name']!;
      if (name.toLowerCase().contains(qLower) && !uniqueMap.containsKey(name.toLowerCase())) {
        uniqueMap[name.toLowerCase()] = {'name': name, 'icon': item['icon']};
      }
    }

    final List<Map<String, dynamic>> list = uniqueMap.values.toList();

    // Sort by relevance:
    // 1. Starts with query
    // 2. Any word inside starts with query
    // 3. Contains query
    // 4. Shorter string length
    list.sort((a, b) {
      final nameA = (a['name'] ?? '').toString().toLowerCase();
      final nameB = (b['name'] ?? '').toString().toLowerCase();

      final startsA = nameA.startsWith(qLower);
      final startsB = nameB.startsWith(qLower);
      if (startsA && !startsB) return -1;
      if (!startsA && startsB) return 1;

      final wordStartsA = nameA.split(RegExp(r'\s+')).any((w) => w.startsWith(qLower));
      final wordStartsB = nameB.split(RegExp(r'\s+')).any((w) => w.startsWith(qLower));
      if (wordStartsA && !wordStartsB) return -1;
      if (!wordStartsA && wordStartsB) return 1;

      return nameA.length.compareTo(nameB.length);
    });

    return list.take(15).toList();
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
