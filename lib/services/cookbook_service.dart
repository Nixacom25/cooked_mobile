import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/cookbook.dart';
import '../models/recipe.dart';
import '../models/shared_cookbook_preview.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

List<Cookbook> _parseCookbooks(String responseBody) {
  final List<dynamic> data = jsonDecode(responseBody);
  final cookbooks = <Cookbook>[];
  for (var item in data) {
    try {
      cookbooks.add(Cookbook.fromJson(item));
    } catch (e) {}
  }
  return cookbooks;
}

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
        final cookbooks = await compute(_parseCookbooks, response.body);
        // Keep the tiles of shared cookbooks still being received.
        final receiving = (myCookbooksNotifier.value ?? const <Cookbook>[])
            .where((cb) => receiveProgressNotifier.value.containsKey(cb.id));
        myCookbooksNotifier.value = [...receiving, ...cookbooks];
        return cookbooks;
      } catch (e) {
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
      final response = await _reliableRequest(
        () async => http.post(
          url,
          headers: await _getHeaders(),
          body: jsonEncode({'name': name, 'recipeIds': recipeIds}),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final dynamic decoded = jsonDecode(response.body);
          // Handle case where backend might return a list with one item or a single object
          final Map<String, dynamic> json = decoded is List
              ? decoded.first
              : decoded;

          final cookbook = Cookbook.fromJson(json);
          _cache[cookbook.id] = cookbook;

          // Publish the server result immediately. Refresh in the background
          // so the modal closes without waiting for a second network request.
          final current = myCookbooksNotifier.value ?? [];
          myCookbooksNotifier.value = [
            cookbook,
            ...current.where(
              (item) => item.id != placeholder?.id && item.id != cookbook.id,
            ),
          ];
          getMyCookbooks(forceRefresh: true).catchError((error) {
            return <Cookbook>[];
          });
          return cookbook;
        } catch (e) {
          rethrow;
        }
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
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
          recipes:
              original.recipes, // Keep recipes for now, sync will refresh them
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
      final response = await _reliableRequest(
        () async => http.put(
          url,
          headers: await _getHeaders(),
          body: jsonEncode({'name': name, 'recipeIds': recipeIds}),
        ),
      );

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

  /// Public link of one of my cookbooks; sharing it lets anyone holding
  /// the link add a copy of the cookbook (and its recipes) to their library.
  Future<String> getShareLink(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id/share');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['link'] as String;
    }
    throw Exception('Unable to share this cookbook.');
  }

  Future<SharedCookbookPreview> getSharedPreview(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/shared/$id');
    final response = await http.get(url, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return SharedCookbookPreview.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) throw const SharedCookbookNotFound();
    throw Exception('Unable to load the shared cookbook.');
  }

  /// Placeholder cookbook id → progress (0..1) of a shared cookbook being
  /// copied into my library. Its "Your cookbooks" tile shows a loader in the
  /// middle and this progress along its bottom edge.
  final ValueNotifier<Map<String, double>> receiveProgressNotifier =
      ValueNotifier(const {});
  final Map<String, Future<Cookbook>> _receiving = {};

  /// Adds a shared cookbook to my library: a placeholder tile (name + recipe
  /// covers from [preview]) appears first in "Your cookbooks" and fills up
  /// while the server copies the recipes, then is swapped for the real one.
  /// Opening the same link twice while it runs reuses the running import.
  Future<Cookbook> receiveShared(SharedCookbookPreview preview) {
    return _receiving[preview.id] ??= _receive(
      preview,
    ).whenComplete(() => _receiving.remove(preview.id));
  }

  Future<Cookbook> _receive(SharedCookbookPreview preview) async {
    if (myCookbooksNotifier.value == null) {
      await getMyCookbooks().catchError((_) => const <Cookbook>[]);
    }

    final now = DateTime.now();
    final placeholder = Cookbook(
      id: 'receiving_${preview.id}',
      name: preview.name,
      recipes: List.generate(
        preview.recipeCount,
        (i) => Recipe(
          id: 'receiving_${preview.id}_$i',
          name: '',
          image: i < preview.coverImages.length ? preview.coverImages[i] : null,
          cookTime: 0,
          kcal: 0,
          steps: const [],
          equipment: const [],
          ingredients: const [],
          isPublic: false,
          isFavorite: false,
          createdAt: now,
          updatedAt: now,
          isPlaceholder: true,
        ),
      ),
      createdAt: now,
      updatedAt: now,
      isPlaceholder: true,
    );
    myCookbooksNotifier.value = [placeholder, ...?myCookbooksNotifier.value];
    _setReceiveProgress(placeholder.id, 0);

    // Eases towards 90% while the request runs, paced on the recipe count
    // so a big cookbook visibly takes longer; the rest fills on success.
    final expectedMs = (1200 + preview.recipeCount * 180).clamp(1200, 6000);
    final started = DateTime.now();
    final ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final t = DateTime.now().difference(started).inMilliseconds / expectedMs;
      _setReceiveProgress(placeholder.id, 0.9 * (1 - math.exp(-2.5 * t)));
    });

    try {
      final cookbook = await _importShared(preview.id);
      ticker.cancel();
      _setReceiveProgress(placeholder.id, 1);
      // Lets the bar visibly reach the end before the tile turns real.
      await Future.delayed(const Duration(milliseconds: 450));
      // A reload meanwhile may already list the copy: never show it twice.
      myCookbooksNotifier.value = [
        cookbook,
        ...?myCookbooksNotifier.value?.where(
          (cb) => cb.id != placeholder.id && cb.id != cookbook.id,
        ),
      ];
      return cookbook;
    } catch (_) {
      ticker.cancel();
      myCookbooksNotifier.value = myCookbooksNotifier.value
          ?.where((cb) => cb.id != placeholder.id)
          .toList();
      rethrow;
    } finally {
      receiveProgressNotifier.value = {...receiveProgressNotifier.value}
        ..remove(placeholder.id);
    }
  }

  void _setReceiveProgress(String id, double value) {
    receiveProgressNotifier.value = {
      ...receiveProgressNotifier.value,
      id: value,
    };
  }

  /// Copies a shared cookbook and its recipes into my library.
  Future<Cookbook> _importShared(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/shared/$id/import');
    final response = await _reliableRequest(
      () async => http.post(url, headers: await _getHeaders()),
    );
    if (response.statusCode == 200) {
      final cookbook = Cookbook.fromJson(jsonDecode(response.body));
      _cache[cookbook.id] = cookbook;
      return cookbook;
    }
    if (response.statusCode == 402)
      throw Exception('402: subscription required');
    if (response.statusCode == 404) throw const SharedCookbookNotFound();
    throw Exception('Unable to add this cookbook.');
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
      final response = await _reliableRequest(
        () async => http.delete(url, headers: await _getHeaders()),
      );
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
        final newRecipes = target.recipes
            .where((r) => r.id != recipeId)
            .toList();
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
    final ids = cb.recipes
        .map((r) => r.id)
        .where((id) => id != recipeId)
        .toList();
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
      final response = await _reliableRequest(
        () async => http.patch(url, headers: await _getHeaders()),
      );
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
