import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/grocery_item.dart';
import '../models/instacart_link_response.dart';
import 'auth_service.dart';
import 'analytics_service.dart';
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
      
      // Auto-cleanup items: bought or expired planned dates
      _autoCleanupItems(items);
      
      myGroceriesNotifier.value = items;
      
      // Analytics log
      AnalyticsService.instance.logGroceryListView(itemCount: items.length);

      return items;
    } else {
      throw Exception('Failed to load grocery list.');
    }
  }

  Future<http.Response> _reliableRequest(
    Future<http.Response> Function() requestCall, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        final response = await requestCall();
        if (response.statusCode < 500) {
          return response;
        }
        throw Exception('Server error: ${response.statusCode}');
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  Future<GroceryItem> addGroceryItem({
    required String name,
    required String quantity,
    String? icon,
    String? recipeId,
    DateTime? date,
    String? source,
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

    try {
      final response = await _reliableRequest(() async => http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          'ingredientName': name,
          'ingredientIcon': icon,
          'quantity': quantity,
          'recipeId': recipeId,
          'plannedDate': date?.toIso8601String().split('T')[0],
        }),
      ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Log Analytics event
        AnalyticsService.instance.logGroceryItemAdded(name: name, source: source);

        // Refresh list to replace placeholder with real data
        await getMyGroceries(forceRefresh: true);
        return GroceryItem.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add item');
      }
    } catch (e) {
      // Remove placeholder on error
      if (myGroceriesNotifier.value != null) {
        myGroceriesNotifier.value = myGroceriesNotifier.value!
            .where((item) => !item.isPlaceholder)
            .toList();
      }
      rethrow;
    }
  }

  Future<InstacartLinkResponse> createInstacartShoppingLink() async {
    final itemsCount = myGroceriesNotifier.value?.length ?? 0;
    AnalyticsService.instance.logInstacartRequestStarted(itemCount: itemsCount);

    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/instacart');
    try {
      final response = await _reliableRequest(() async => http.post(
        url,
        headers: await _getHeaders(),
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final instacartRes = InstacartLinkResponse.fromJson(data);

        AnalyticsService.instance.logInstacartRequestSuccess(
          url: instacartRes.url,
          itemCount: instacartRes.itemCount,
        );

        return instacartRes;
      } else if (response.statusCode == 400) {
        throw Exception('Your grocery list is empty. Add ingredients from a recipe to get started.');
      } else {
        throw Exception('Unable to connect to Instacart right now. Please try again.');
      }
    } catch (e) {
      AnalyticsService.instance.logInstacartRequestFailed(error: e.toString());
      rethrow;
    }
  }

  Future<void> toggleBought(String id) async {
    if (id.isEmpty) return;

    // 1. Optimistic local update
    _updateLocalToggleStatus(id);

    // 2. Debounce backend call (1s delay for better reliability)
    _toggleDebouncers[id]?.cancel();
    _toggleDebouncers[id] = Timer(const Duration(seconds: 1), () async {
      final currentIsBought = _getCurrentIsBought(id);
      final originalIsBought = _originalToggleStates[id];

      // Only send to backend if the final state is different from the original
      if (originalIsBought != null && currentIsBought != originalIsBought) {
        try {
          final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/$id/toggle');
          await _reliableRequest(() async => http.put(url, headers: await _getHeaders()));
        } catch (e) {
          print('Error syncing toggle state for grocery $id: $e');
          // On total failure, refresh list to revert UI
          await getMyGroceries(forceRefresh: true);
        }
      }

      _toggleDebouncers.remove(id);
      _originalToggleStates.remove(id);
    });
  }

  void _updateLocalToggleStatus(String id) {
    if (myGroceriesNotifier.value == null) return;
    
    final newList = List<GroceryItem>.from(myGroceriesNotifier.value!).map((item) {
      if (item.id == id) {
        // Remember original state before any toggles in this sequence
        if (!_originalToggleStates.containsKey(id)) {
          _originalToggleStates[id] = item.isBought;
        }
        // Create a new instance with the toggled state to ensure ValueNotifier detects change
        return GroceryItem(
          id: item.id,
          ingredientId: item.ingredientId,
          ingredientName: item.ingredientName,
          ingredientIcon: item.ingredientIcon,
          recipeId: item.recipeId,
          recipeName: item.recipeName,
          recipeImage: item.recipeImage,
          quantity: item.quantity,
          isBought: !item.isBought,
          plannedDate: item.plannedDate,
          createdAt: item.createdAt,
          updatedAt: DateTime.now(),
          isPlaceholder: item.isPlaceholder,
        );
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
    String itemName = '';
    if (myGroceriesNotifier.value != null) {
      final found = myGroceriesNotifier.value!.firstWhere(
        (item) => item.id == id,
        orElse: () => GroceryItem(
          id: '',
          ingredientName: '',
          quantity: '',
          isBought: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      itemName = found.ingredientName;

      // 1. Optimistic remove
      myGroceriesNotifier.value = myGroceriesNotifier.value!
          .where((item) => item.id != id)
          .toList();
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/$id');
    try {
      final response = await _reliableRequest(() async => http.delete(url, headers: await _getHeaders()));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete item');
      }

      if (itemName.isNotEmpty) {
        AnalyticsService.instance.logGroceryItemRemoved(name: itemName);
      }
    } catch (e) {
      // Revert on error
      await getMyGroceries(forceRefresh: true);
      throw Exception('Failed to delete grocery item.');
    }
  }

  Future<void> _autoCleanupItems(List<GroceryItem> items) async {
    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(hours: 24));
    
    // 1. Clean up items bought more than 24h ago
    // 2. Clean up items with a planned date that passed more than 24h ago
    final toDelete = items.where((item) {
      if (item.isBought && item.updatedAt.isBefore(oneDayAgo)) return true;
      if (item.plannedDate != null) {
        if (item.plannedDate!.add(const Duration(hours: 48)).isBefore(now)) return true;
      }
      return false;
    }).toList();

    for (final item in toDelete) {
      try {
        final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/${item.id}');
        http.delete(url, headers: await _getHeaders());
        items.remove(item);
      } catch (e) {
        print('Error auto-cleaning item ${item.id}: $e');
      }
    }
  }

  void clearData() {
    myGroceriesNotifier.value = null;
    for (final timer in _toggleDebouncers.values) {
      timer.cancel();
    }
    _toggleDebouncers.clear();
    _originalToggleStates.clear();
  }
}
