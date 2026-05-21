import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/cookbook.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class CookbookService {
  CookbookService._privateConstructor();
  static final CookbookService instance = CookbookService._privateConstructor();

  final ValueNotifier<List<Cookbook>?> myCookbooksNotifier = ValueNotifier(
    null,
  );

  final Map<String, Cookbook> _cache = {};

  void clearCache() {
    _cache.clear();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Cookbook>> getMyCookbooks({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _cache.clear();
    }
    if (!forceRefresh && myCookbooksNotifier.value != null) {
      return myCookbooksNotifier.value!;
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        final cookbooks = <Cookbook>[];
        for (var item in data) {
          try {
            cookbooks.add(Cookbook.fromJson(item));
          } catch (e) {
            debugPrint('Error parsing individual cookbook: $e');
            // Skip this one
          }
        }
        myCookbooksNotifier.value = cookbooks;
        return cookbooks;
      } catch (e) {
        debugPrint('ERROR parsing cookbooks: $e');
        debugPrint('BODY: ${response.body}');
        rethrow;
      }
    } else {
      throw Exception('Unable to load your cookbooks.');
    }
  }

  Future<Cookbook> getCookbook(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache.containsKey(id)) {
      return _cache[id]!;
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final cookbook = Cookbook.fromJson(jsonDecode(response.body));
      _cache[id] = cookbook;
      return cookbook;
    } else {
      throw Exception('Unable to load the cookbook.');
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
        // If success or a non-retryable client error (4xx), return it
        if (response.statusCode < 500) {
          return response;
        }
        // Server error (500+), try again
        throw Exception('Server error: ${response.statusCode}');
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        // Exponential backoff: 2s, 4s, 6s...
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
  }

  Future<Cookbook> createCookbook(String name, List<String> recipeIds) async {
    // 1. Optimistic local update (Placeholder)
    Cookbook? placeholder;
    if (myCookbooksNotifier.value != null) {
      placeholder = Cookbook(
        id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        recipes: [], // Recipes will be loaded on sync
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPlaceholder: true,
      );
      myCookbooksNotifier.value = [placeholder, ...myCookbooksNotifier.value!];
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks');
    try {
      final response = await _reliableRequest(() async => http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'recipeIds': recipeIds}),
      ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('COOKBOOK CREATE RAW BODY: ${response.body}');
        try {
          final dynamic decoded = jsonDecode(response.body);
          // Handle case where backend might return a list with one item or a single object
          final Map<String, dynamic> json = decoded is List ? decoded.first : decoded;
          
          final cookbook = Cookbook.fromJson(json);
          _cache[cookbook.id] = cookbook;
          
          // Background refresh to get the real object and remove placeholder
          try {
            await getMyCookbooks(forceRefresh: true);
          } catch (e) {
             debugPrint('Non-critical background refresh failed: $e');
          }
          return cookbook;
        } catch (e, stack) {
          debugPrint('CRITICAL ERROR parsing new cookbook: $e');
          debugPrint('STACKTRACE: $stack');
          debugPrint('RAW JSON: ${response.body}');
          rethrow;
        }
      } else {
        debugPrint('COOKBOOK CREATE SERVER ERROR: ${response.statusCode}');
        debugPrint('SERVER BODY: ${response.body}');
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint('TOTAL FAILURE in createCookbook: $e');
      // Revert placeholder on error
      if (myCookbooksNotifier.value != null && placeholder != null) {
        myCookbooksNotifier.value = myCookbooksNotifier.value!
            .where((cb) => cb.id != placeholder!.id)
            .toList();
      }
      rethrow;
    }
  }

  Future<Cookbook> updateCookbook(
    String id,
    String name,
    List<String> recipeIds,
  ) async {
    // 1. Optimistic local update
    Cookbook? original;
    if (myCookbooksNotifier.value != null) {
      final newList = List<Cookbook>.from(myCookbooksNotifier.value!);
      final index = newList.indexWhere((cb) => cb.id == id);
      if (index != -1) {
        original = newList[index];
        newList[index] = Cookbook(
          id: id,
          name: name,
          recipes: original.recipes, // Keep recipes for now, sync will refresh them
          createdAt: original.createdAt,
          updatedAt: DateTime.now(),
          isPinned: original.isPinned,
          isPlaceholder: original.isPlaceholder,
        );
        myCookbooksNotifier.value = newList;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id');
    try {
      final response = await _reliableRequest(() async => http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'recipeIds': recipeIds}),
      ));

      if (response.statusCode == 200) {
        final cookbook = Cookbook.fromJson(jsonDecode(response.body));
        _cache[id] = cookbook;
        await getMyCookbooks(forceRefresh: true);
        return cookbook;
      } else {
        throw Exception('Unable to update cookbook.');
      }
    } catch (e) {
      // Revert on error
      await getMyCookbooks(forceRefresh: true);
      rethrow;
    }
  }

  Future<void> deleteCookbook(String id) async {
    // 1. Optimistic local update
    if (myCookbooksNotifier.value != null) {
      myCookbooksNotifier.value = myCookbooksNotifier.value!
          .where((cb) => cb.id != id)
          .toList();
    }
    _cache.remove(id);

    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id');
    try {
      final response = await _reliableRequest(() async => http.delete(url, headers: await _getHeaders()));
      if (response.statusCode != 200) {
        throw Exception('Unable to delete cookbook.');
      }
    } catch (e) {
      // Revert or refresh on error
      await getMyCookbooks(forceRefresh: true);
      rethrow;
    }
  }

  Future<Cookbook> addRecipeToCookbook(
    String cookbookId,
    String recipeId,
  ) async {
    // 1. Optimistic local update
    if (myCookbooksNotifier.value != null) {
      final newList = List<Cookbook>.from(myCookbooksNotifier.value!);
      final index = newList.indexWhere((cb) => cb.id == cookbookId);
      if (index != -1) {
        final target = newList[index];
        // Only update if not already there
        if (!target.recipes.any((r) => r.id == recipeId)) {
          // No full recipe object here, rely on sync for the full list.
        }
      }
    }

    // Force refresh to ensure we have the latest recipe list before updating
    final cb = await getCookbook(cookbookId, forceRefresh: true);
    final ids = cb.recipes.map((r) => r.id).toList();
    if (!ids.contains(recipeId)) {
      ids.add(recipeId);
      return updateCookbook(cookbookId, cb.name, ids);
    }
    return cb;
  }

  Future<Cookbook> removeRecipeFromCookbook(
    String cookbookId,
    String recipeId,
  ) async {
    // 1. Optimistic local update
    if (myCookbooksNotifier.value != null) {
      final newList = List<Cookbook>.from(myCookbooksNotifier.value!);
      final index = newList.indexWhere((cb) => cb.id == cookbookId);
      if (index != -1) {
        final target = newList[index];
        final newRecipes = target.recipes.where((r) => r.id != recipeId).toList();
        newList[index] = Cookbook(
          id: target.id,
          name: target.name,
          recipes: newRecipes,
          createdAt: target.createdAt,
          updatedAt: DateTime.now(),
          isPinned: target.isPinned,
          isPlaceholder: target.isPlaceholder,
        );
        myCookbooksNotifier.value = newList;
      }
    }

    final cb = await getCookbook(cookbookId, forceRefresh: true);
    final ids = cb.recipes.map((r) => r.id).where((id) => id != recipeId).toList();
    return updateCookbook(cookbookId, cb.name, ids);
  }

  Future<Cookbook> togglePin(String id) async {
    // 1. Optimistic local update
    Cookbook? target;
    if (myCookbooksNotifier.value != null) {
      final newList = List<Cookbook>.from(myCookbooksNotifier.value!);
      final index = newList.indexWhere((cb) => cb.id == id);
      if (index != -1) {
        target = newList[index];
        newList[index] = Cookbook(
          id: target.id,
          name: target.name,
          recipes: target.recipes,
          createdAt: target.createdAt,
          updatedAt: DateTime.now(),
          isPinned: !target.isPinned,
          isPlaceholder: target.isPlaceholder,
        );
        myCookbooksNotifier.value = newList;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id/pin');
    try {
      final response = await _reliableRequest(() async => http.patch(url, headers: await _getHeaders()));
      if (response.statusCode == 200) {
        final cookbook = Cookbook.fromJson(jsonDecode(response.body));
        _cache[id] = cookbook;
        return cookbook;
      } else {
        throw Exception('Unable to pin/unpin cookbook.');
      }
    } catch (e) {
      // Revert on error
      await getMyCookbooks(forceRefresh: true);
      rethrow;
    }
  }

  void clearData() {
    myCookbooksNotifier.value = null;
  }
}
