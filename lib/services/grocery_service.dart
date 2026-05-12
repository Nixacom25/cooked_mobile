import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/grocery_item.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class GroceryService {
  GroceryService._privateConstructor();
  static final GroceryService instance = GroceryService._privateConstructor();
  
  final ValueNotifier<List<GroceryItem>?> myGroceriesNotifier = ValueNotifier(null);

  // Debouncing for toggles
  final Map<String, Timer> _toggleDebouncers = {};
  final Map<String, bool> _originalToggleStates = {};

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<GroceryItem>> getMyGroceries({bool forceRefresh = false}) async {
    if (!forceRefresh && myGroceriesNotifier.value != null) {
      return myGroceriesNotifier.value!;
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final items = data.map((json) => GroceryItem.fromJson(json)).toList();
      myGroceriesNotifier.value = items;
      return items;
    } else {
      throw Exception('Failed to load grocery list.');
    }
  }

  Future<GroceryItem> addGroceryItem({
    required String name,
    required String quantity,
    String? icon,
    String? recipeId,
    DateTime? date,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items');

    // 1. Insert partial skeleton (placeholder)
    if (myGroceriesNotifier.value != null) {
      final placeholder = GroceryItem(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        ingredientName: name,
        ingredientIcon: icon,
        quantity: quantity,
        isBought: false,
        plannedDate: date,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPlaceholder: true,
      );
      myGroceriesNotifier.value = [placeholder, ...myGroceriesNotifier.value!];
    }

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'ingredientName': name,
        'ingredientIcon': icon,
        'quantity': quantity,
        'recipeId': recipeId,
        'plannedDate': date?.toIso8601String().split('T')[0],
      }),
    );

    if (response.statusCode == 200) {
      // Refresh list to replace placeholder with real data
      await getMyGroceries(forceRefresh: true);
      return GroceryItem.fromJson(jsonDecode(response.body));
    } else {
      // Remove placeholder on error
      if (myGroceriesNotifier.value != null) {
        myGroceriesNotifier.value = myGroceriesNotifier.value!
            .where((item) => !item.isPlaceholder)
            .toList();
      }
      throw Exception('Failed to add item to grocery list.');
    }
  }

  Future<void> toggleBought(String id) async {
    if (id.isEmpty) return;

    // 1. Optimistic local update
    _updateLocalToggleStatus(id);

    // 2. Debounce backend call (5s delay)
    _toggleDebouncers[id]?.cancel();
    _toggleDebouncers[id] = Timer(const Duration(seconds: 5), () async {
      final currentIsBought = _getCurrentIsBought(id);
      final originalIsBought = _originalToggleStates[id];

      // Only send to backend if the final state is different from the original
      if (originalIsBought != null && currentIsBought != originalIsBought) {
        try {
          final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/$id/toggle');
          final response = await http.put(url, headers: await _getHeaders());

          if (response.statusCode == 200) {
            // Silently refresh in background
            getMyGroceries(forceRefresh: true).then((_) => null).catchError((_) => null);
          }
        } catch (e) {
          print('Error syncing toggle state for grocery $id: $e');
        }
      }

      _toggleDebouncers.remove(id);
      _originalToggleStates.remove(id);
    });
  }

  void _updateLocalToggleStatus(String id) {
    if (myGroceriesNotifier.value == null) return;
    
    final newList = myGroceriesNotifier.value!.map((item) {
      if (item.id == id) {
        // Remember original state before any toggles in this sequence
        if (!_originalToggleStates.containsKey(id)) {
          _originalToggleStates[id] = item.isBought;
        }
        item.isBought = !item.isBought;
      }
      return item;
    }).toList();
    
    myGroceriesNotifier.value = newList;
  }

  bool _getCurrentIsBought(String id) {
    if (myGroceriesNotifier.value == null) return false;
    for (var item in myGroceriesNotifier.value!) {
      if (item.id == id) return item.isBought;
    }
    return false;
  }

  Future<void> deleteGroceryItem(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/$id');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete grocery item.');
    }
    // For delete, we keep it simple: refresh list
    await getMyGroceries(forceRefresh: true);
  }

  void clearData() {
    myGroceriesNotifier.value = null;
  }
}
