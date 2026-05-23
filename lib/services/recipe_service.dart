import 'dart:convert';
import 'dart:async';
import 'package:cooked/services/cookbook_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/api_config.dart';
import '../models/recipe.dart';
import '../models/creator.dart';
import 'package:cooked/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeService {
  RecipeService._privateConstructor();
  static final RecipeService instance = RecipeService._privateConstructor();

  final ValueNotifier<List<Recipe>?> myRecipesNotifier = ValueNotifier(null);
  final ValueNotifier<List<Recipe>?> recentImportsNotifier = ValueNotifier(null);
  final ValueNotifier<List<Recipe>?> homeSuggestionsNotifier = ValueNotifier(null);
  
  // Cache for explore data
  final Map<String, dynamic> _cache = {};

  static const String _persistentCachePrefix = 'persistent_cache_v2_';

  Future<void> _writeToPersistentCache(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      };
      await prefs.setString('$_persistentCachePrefix$key', jsonEncode(cacheData));
    } catch (_) {}
  }

  Future<dynamic> _readFromPersistentCache(String key, Duration ttl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('$_persistentCachePrefix$key');
      if (jsonStr == null) return null;

      final decoded = jsonDecode(jsonStr);
      final int timestamp = decoded['timestamp'] as int;
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      if (DateTime.now().difference(cachedTime) > ttl) {
        await prefs.remove('$_persistentCachePrefix$key');
        return null;
      }
      return decoded['data'];
    } catch (_) {
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
    SharedPreferences.getInstance().then((prefs) {
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_persistentCachePrefix)) {
          prefs.remove(key);
        }
      }
    }).catchError((_) {});
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> scan(XFile image) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/scan');
    final token = await AuthService.instance.getToken();

    final request = http.MultipartRequest('POST', url);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final bytes = await image.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: image.name),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Scan failed. Please try again.';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}
      
      if (response.statusCode == 402) {
        throw Exception('402: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> scanTyped(List<String> ingredients) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/scan-typed');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'ingredients': ingredients,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Generation failed. Please try again.';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}

      if (response.statusCode == 402) {
        throw Exception('402: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  Future<List<Recipe>> generateAiRecipes(List<String> ingredients) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/generate-ai-recipes');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'ingredients': ingredients,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {
      String errorMessage = 'Failed to generate recipes. Please try again.';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}

      if (response.statusCode == 402) {
        throw Exception('402: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  Future<List<Recipe>> getMyRecipes({bool forceRefresh = false}) async {
    if (!forceRefresh && myRecipesNotifier.value != null) {
      return myRecipesNotifier.value!;
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final recipes = data.map((json) => Recipe.fromJson(json)).toList();
      myRecipesNotifier.value = recipes;
      return recipes;
    } else {
      throw Exception('Unable to load your recipes.');
    }
  }

  Future<Recipe> getRecipe(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Unable to load the recipe.');
    }
  }

  Future<Recipe> createRecipe(
    Recipe recipe, {
    List<String>? cookbookIds,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': recipe.name,
        'image': recipe.image,
        'cookTime': recipe.cookTime,
        'prepTime': recipe.prepTime,
        'kcal': recipe.kcal,
        'servings': recipe.servings,
        'tips': recipe.tips,
        'ingredients': recipe.ingredients
            .map(
              (ing) => {
                'name': ing.name,
                'quantity': ing.quantity,
                'icon': ing.icon,
              },
            )
            .toList(),
        'steps': recipe.steps,
        'equipment': recipe.equipment,
        'sourceUrl': recipe.sourceUrl,
        'origin': recipe.origin,
        'cookbookIds': cookbookIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final saved = Recipe.fromJson(jsonDecode(response.body));
      
      // 1. Insert partial skeleton (placeholder)
      if (myRecipesNotifier.value != null) {
        final placeholder = Recipe(
          id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
          name: recipe.name,
          cookTime: recipe.cookTime,
          kcal: recipe.kcal,
          steps: [],
          equipment: [],
          ingredients: [],
          isPublic: false,
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPlaceholder: true,
          isSuggested: true,
        );
        myRecipesNotifier.value = [placeholder, ...myRecipesNotifier.value!];
      }

      // Trigger background refresh 
      await getMyRecipes(forceRefresh: true);
      await getRecentImports(forceRefresh: true);
      
      // Cleanup from temporary suggestions
      await _removeTemporarySuggestion(recipe.name);
      
      CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
      return saved;
    } else {
      print('Failed to save recipe: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to save recipe: ${response.body}');
    }
  }


  Future<List<Recipe>> getExploreRecipes({String? cuisine, String? category, int page = 0, int size = 10, bool forceRefresh = false}) async {
    final cacheKey = 'explore_recipes_${cuisine ?? ''}_${category ?? ''}_${page}_$size';
    if (!forceRefresh) {
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<Recipe>;
      }
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(hours: 12));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList.map((json) => Recipe.fromJson(json)).toList();
        _cache[cacheKey] = results;
        return results;
      }
    }

    final cuisineParam = cuisine != null ? '&cuisine=$cuisine' : '';
    final categoryParam = category != null ? '&category=$category' : '';
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/explore?page=$page&size=$size$cuisineParam$categoryParam',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      final results = content.map((json) => Recipe.fromJson(json)).toList();
      _cache[cacheKey] = results;
      await _writeToPersistentCache(cacheKey, content);
      return results;
    } else {
      throw Exception('Unable to load explore recipes.');
    }
  }

  Future<List<Recipe>> getHomeSuggestions({bool forceRefresh = false}) async {
    if (!forceRefresh && homeSuggestionsNotifier.value != null) {
      return homeSuggestionsNotifier.value!;
    }

    const cacheKey = 'home_suggestions';
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<Recipe>;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/suggested');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final results = data.map((json) => Recipe.fromJson(json)).toList();
      
      // Merge with temporary local suggestions
      final merged = await _mergeTemporarySuggestions(results);
      
      _cache[cacheKey] = merged;
      homeSuggestionsNotifier.value = merged;
      return merged;
    } else {
      throw Exception('Unable to load home suggestions.');
    }
  }

  static const String _tempSuggestionsKey = 'temp_suggestions_v1';

  Future<void> saveScanResults(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? existingJson = prefs.getString(_tempSuggestionsKey);
    List<Recipe> current = [];
    
    if (existingJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(existingJson);
        current = decoded.map((j) => Recipe.fromJson(j)).toList();
      } catch (_) {}
    }

    // Set expiration to 3 days from now for new ones
    final expiry = DateTime.now().add(const Duration(days: 3));
    final newOnes = recipes.map((r) {
      // Create a copy with expiresAt
      return Recipe(
        id: r.id,
        name: r.name,
        image: r.image,
        cookTime: r.cookTime,
        prepTime: r.prepTime,
        kcal: r.kcal,
        steps: r.steps,
        equipment: r.equipment,
        ingredients: r.ingredients,
        isPublic: r.isPublic,
        isFavorite: r.isFavorite,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        category: r.category,
        creator: r.creator,
        sourceUrl: r.sourceUrl,
        servings: r.servings,
        tips: r.tips,
        expiresAt: expiry,
        origin: 'SUGGESTED',
        cuisine: r.cuisine,
        isInCookbook: r.isInCookbook,
        isPlaceholder: r.isPlaceholder,
      );
    }).toList();

    // Add without duplicates (by name or ID)
    for (var r in newOnes) {
      if (!current.any((c) => c.name.toLowerCase() == r.name.toLowerCase())) {
        current.insert(0, r);
      }
    }

    // Save back
    await prefs.setString(_tempSuggestionsKey, jsonEncode(current.map((r) => r.toJson()).toList()));
    
    // Refresh notifier if already has data
    if (homeSuggestionsNotifier.value != null) {
      await getHomeSuggestions(forceRefresh: true);
    }
  }

  Future<void> _removeTemporarySuggestion(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingJson = prefs.getString(_tempSuggestionsKey);
    if (existingJson == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(existingJson);
      final List<Recipe> local = decoded.map((j) => Recipe.fromJson(j)).toList();
      final filtered = local.where((r) => r.name.toLowerCase() != name.toLowerCase()).toList();
      
      if (filtered.length != local.length) {
        await prefs.setString(_tempSuggestionsKey, jsonEncode(filtered.map((r) => r.toJson()).toList()));
        if (homeSuggestionsNotifier.value != null) {
          await getHomeSuggestions(forceRefresh: true);
        }
      }
    } catch (_) {}
  }

  Future<List<Recipe>> _mergeTemporarySuggestions(List<Recipe> backendResults) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingJson = prefs.getString(_tempSuggestionsKey);
    if (existingJson == null) return backendResults;

    try {
      final List<dynamic> decoded = jsonDecode(existingJson);
      final List<Recipe> local = decoded.map((j) => Recipe.fromJson(j)).toList();
      
      final now = DateTime.now();
      // Filter out expired ones
      final validLocal = local.where((r) => r.expiresAt != null && r.expiresAt!.isAfter(now)).toList();
      
      // If some expired, update storage
      if (validLocal.length != local.length) {
        await prefs.setString(_tempSuggestionsKey, jsonEncode(validLocal.map((r) => r.toJson()).toList()));
      }

      if (validLocal.isEmpty) return backendResults;

      // Merge: Local ones first, then backend
      final List<Recipe> merged = [...validLocal];
      for (var r in backendResults) {
        if (!merged.any((m) => m.name.toLowerCase() == r.name.toLowerCase())) {
          merged.add(r);
        }
      }
      return merged;
    } catch (_) {
      return backendResults;
    }
  }

  Future<List<Map<String, dynamic>>> getExploreCuisines({bool forceRefresh = false}) async {
    const cacheKey = 'explore_cuisines';
    if (!forceRefresh) {
      if (_cache.containsKey(cacheKey)) {
        return List<Map<String, dynamic>>.from(_cache[cacheKey]);
      }
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(hours: 24));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        _cache[cacheKey] = results;
        return results;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/explore/cuisines');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final results = data.map((item) => Map<String, dynamic>.from(item)).toList();
      _cache[cacheKey] = results;
      await _writeToPersistentCache(cacheKey, results);
      return results;
    } else {
      throw Exception('Unable to load cuisines.');
    }
  }

  Future<List<Map<String, dynamic>>> getExploreCategories({bool forceRefresh = false}) async {
    const cacheKey = 'explore_categories';
    if (!forceRefresh) {
      if (_cache.containsKey(cacheKey)) {
        return List<Map<String, dynamic>>.from(_cache[cacheKey]);
      }
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(hours: 24));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        _cache[cacheKey] = results;
        return results;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/explore/categories');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final results = data.map((item) => Map<String, dynamic>.from(item)).toList();
      _cache[cacheKey] = results;
      await _writeToPersistentCache(cacheKey, results);
      return results;
    } else {
      throw Exception('Unable to load categories.');
    }
  }


  Future<List<Creator>> getTopCreators({int page = 0, int size = 10}) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/top-creators?page=$page&size=$size',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Creator.fromJson(json)).toList();
    } else {
      throw Exception('Unable to load creators.');
    }
  }

  Future<List<Recipe>> getPopularRecipes({
    String? category,
    String? cuisine,
    int page = 0,
    int size = 10,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'popular_recipes_${category ?? ''}_${cuisine ?? ''}_${page}_$size';
    if (!forceRefresh) {
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<Recipe>;
      }
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(hours: 12));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList.map((json) => Recipe.fromJson(json)).toList();
        _cache[cacheKey] = results;
        return results;
      }
    }

    final categoryParam = category != null ? '&category=$category' : '';
    final cuisineParam = cuisine != null ? '&cuisine=$cuisine' : '';
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/popular?page=$page&size=$size$categoryParam$cuisineParam',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      final results = content.map((json) => Recipe.fromJson(json)).toList();
      _cache[cacheKey] = results;
      await _writeToPersistentCache(cacheKey, content);
      return results;
    } else {
      throw Exception('Unable to load popular recipes.');
    }
  }

  Future<Recipe> importRecipeFromUrl(String url) async {
    final endpoint = Uri.parse('${ApiConfig.baseUrl}/recipes/import');
    final response = await http.post(
      endpoint,
      headers: await _getHeaders(),
      body: jsonEncode({'url': url}),
    );

    if (response.statusCode == 200) {
      final recipe = Recipe.fromJson(jsonDecode(response.body));
      
      // 1. Insert partial skeleton (placeholder)
      if (recentImportsNotifier.value != null) {
        final placeholder = Recipe(
          id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Importing recipe...',
          cookTime: 0,
          kcal: 0,
          steps: [],
          equipment: [],
          ingredients: [],
          isPublic: false,
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPlaceholder: true,
          isSuggested: true,
        );
        recentImportsNotifier.value = [placeholder, ...recentImportsNotifier.value!];
      }
      if (myRecipesNotifier.value != null) {
        final placeholder = Recipe(
          id: 'pending_my_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Importing recipe...',
          cookTime: 0,
          kcal: 0,
          steps: [],
          equipment: [],
          ingredients: [],
          isPublic: false,
          isFavorite: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPlaceholder: true,
          isSuggested: true,
        );
        myRecipesNotifier.value = [placeholder, ...myRecipesNotifier.value!];
      }

      await getMyRecipes(forceRefresh: true);
      await getRecentImports(forceRefresh: true);
      CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
      return recipe;
    } else {
      String errorMessage = 'Import failed';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}

      if (response.statusCode == 402) {
        throw Exception('402: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  Future<String> getShareLink(String id) async {
    final endpoint = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/share');
    final response = await http.get(endpoint, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['link'];
    } else {
      throw Exception('Failed to generate share link');
    }
  }

  Future<List<String>> getTrendingAiDishes() async {
    final endpoint = Uri.parse('${ApiConfig.baseUrl}/recipes/trending-ai');
    final response = await http.get(endpoint, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load trending AI dishes');
    }
  }

  Future<List<Map<String, dynamic>>> searchWeb(String query) async {
    final endpoint = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/web-search?query=${Uri.encodeComponent(query)}',
    );
    try {
      final response = await http.get(endpoint, headers: await _getHeaders())
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        String errorMessage = 'Web search failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {}

        if (response.statusCode == 402) {
          throw Exception('402: $errorMessage');
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Search took too long. Please try again.');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> getRecentImports({int page = 0, int size = 6, bool forceRefresh = false}) async {
    if (!forceRefresh && page == 0 && recentImportsNotifier.value != null) {
      return recentImportsNotifier.value!;
    }
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/imports?page=$page&size=$size',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      final recipes = content.map((json) => Recipe.fromJson(json)).toList();
      recentImportsNotifier.value = recipes;
      return recipes;
    } else {
      throw Exception('Unable to load recent imports.');
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

  Future<Recipe> validateRecipe(String id) async {
    // 1. Optimistic local update
    if (myRecipesNotifier.value != null) {
      final newList = List<Recipe>.from(myRecipesNotifier.value!);
      final idx = newList.indexWhere((r) => r.id == id);
      if (idx != -1) {
        newList[idx] = newList[idx].copyWith(isValidated: true);
        myRecipesNotifier.value = newList;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/validate');
    try {
      final response = await _reliableRequest(() async => http.put(url, headers: await _getHeaders()));
      if (response.statusCode == 200) {
        final validated = Recipe.fromJson(jsonDecode(response.body));
        
        // Update local state with the actual backend result (handles ID changes if cloned)
        if (myRecipesNotifier.value != null) {
          final newList = List<Recipe>.from(myRecipesNotifier.value!);
          final idx = newList.indexWhere((r) => r.id == id || r.name.toLowerCase() == validated.name.toLowerCase());
          if (idx != -1) {
            newList[idx] = validated;
          } else {
            newList.insert(0, validated);
          }
          myRecipesNotifier.value = newList;
        }

        // Background cleanup
        _removeTemporarySuggestion(validated.name).catchError((_) => null);
        CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
        return validated;
      } else {
        throw Exception('Failed to validate recipe.');
      }
    } catch (e) {
      await getMyRecipes(forceRefresh: true);
      rethrow;
    }
  }

  Future<bool> deleteRecipe(String id) async {
    // 1. Optimistic remove
    if (myRecipesNotifier.value != null) {
      myRecipesNotifier.value = myRecipesNotifier.value!
          .where((r) => r.id != id)
          .toList();
    }
    if (recentImportsNotifier.value != null) {
      recentImportsNotifier.value = recentImportsNotifier.value!
          .where((r) => r.id != id)
          .toList();
    }
    if (homeSuggestionsNotifier.value != null) {
      homeSuggestionsNotifier.value = homeSuggestionsNotifier.value!
          .where((r) => r.id != id)
          .toList();
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id');
    try {
      final response = await _reliableRequest(() async => http.delete(url, headers: await _getHeaders()));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _cache.removeWhere((key, value) => key.contains(id));
        CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
        return true;
      }
      throw Exception('Delete failed');
    } catch (e) {
      await getMyRecipes(forceRefresh: true);
      return false;
    }
  }

  void clearData() {
    myRecipesNotifier.value = null;
    recentImportsNotifier.value = null;
    homeSuggestionsNotifier.value = null;
    clearCache();
  }

  Future<Recipe> togglePin(String id) async {
    // 1. Optimistic local update
    if (myRecipesNotifier.value != null) {
      final newList = List<Recipe>.from(myRecipesNotifier.value!);
      final idx = newList.indexWhere((r) => r.id == id);
      if (idx != -1) {
        newList[idx] = newList[idx].copyWith(isPinned: !newList[idx].isPinned);
        myRecipesNotifier.value = newList;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/pin');
    try {
      final response = await _reliableRequest(() async => http.patch(url, headers: await _getHeaders()));
      if (response.statusCode == 200) {
        final updated = Recipe.fromJson(jsonDecode(response.body));
        return updated;
      } else {
        throw Exception('Failed to toggle pin status.');
      }
    } catch (e) {
      await getMyRecipes(forceRefresh: true);
      rethrow;
    }
  }
}
