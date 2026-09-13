import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../services/user_service.dart';


class HistoryService {
  HistoryService._privateConstructor() {
    // Automatically reload history when user changes
    UserService.instance.currentUserNotifier.addListener(() {
      loadHistory();
    });
  }
  static final HistoryService instance = HistoryService._privateConstructor();

  static const String _baseKey = 'recently_viewed_recipes';

  String _getKey() {
    final user = UserService.instance.currentUserNotifier.value;
    final userId = user != null ? (user['id']?.toString() ?? 'guest') : 'guest';
    return '${_baseKey}_$userId';
  }

  final ValueNotifier<List<Recipe>> recentlyViewedNotifier = ValueNotifier([]);

  Future<void> init() async {
    await loadHistory();
  }

  void clearData() {
    recentlyViewedNotifier.value = [];
  }

  List<Recipe> _decode(List<String> jsonList) {
    return jsonList
        .map((item) {
          try {
            return Recipe.fromJson(jsonDecode(item));
          } catch (e) {
            debugPrint('HistoryService: Failed to decode item: $e');
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();
  }

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey();
      List<Recipe> recipes = _decode(prefs.getStringList(key) ?? []);

      // A recipe viewed before the logged-in user finished loading is
      // persisted under the guest key; fold it into the real user's
      // history once so it doesn't silently disappear after login.
      const guestKey = '${_baseKey}_guest';
      if (key != guestKey) {
        final guestJsonList = prefs.getStringList(guestKey);
        if (guestJsonList != null && guestJsonList.isNotEmpty) {
          final guestRecipes = _decode(guestJsonList);
          for (final r in guestRecipes.reversed) {
            recipes.removeWhere((existing) =>
                (existing.id.isNotEmpty && existing.id == r.id) ||
                (existing.name.toLowerCase() == r.name.toLowerCase()));
            recipes.insert(0, r);
          }
          if (recipes.length > 15) {
            recipes = recipes.sublist(0, 15);
          }
          await prefs.setStringList(
            key,
            recipes.map((r) => jsonEncode(r.toJson())).toList(),
          );
          await prefs.remove(guestKey);
        }
      }

      recentlyViewedNotifier.value = recipes;
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> addToHistory(Recipe recipe) async {
    try {
      final List<Recipe> current = List.from(recentlyViewedNotifier.value);
      
      // Remove if already exists (by ID or by Name to catch duplicates from different sources)
      current.removeWhere((r) => 
        (r.id.isNotEmpty && r.id == recipe.id) || 
        (r.name.toLowerCase() == recipe.name.toLowerCase())
      );
      
      // Add to start
      current.insert(0, recipe);
      debugPrint('HistoryService: Added recipe ${recipe.name} to history. Total: ${current.length}');
      
      // Limit to 15 items
      if (current.length > 15) {
        current.removeLast();
      }

      recentlyViewedNotifier.value = current;

      // Persist
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList = current
          .map((r) => jsonEncode(r.toJson()))
          .toList();
      await prefs.setStringList(_getKey(), jsonList);
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      recentlyViewedNotifier.value = [];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getKey());
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
