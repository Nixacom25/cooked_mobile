import 'dart:convert';
import 'dart:async';
import 'package:cooked/services/cookbook_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_config.dart';
import '../models/recipe.dart';
import '../models/creator.dart';
import 'package:cooked/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cooked/services/database_service.dart';

// Top-level parsing functions for compute()
List<Recipe> _parseRecipesList(String responseBody) {
  final List<dynamic> data = jsonDecode(responseBody);
  return data.map((json) => Recipe.fromJson(json)).toList();
}

List<Recipe> _parseExploreRecipesData(String responseBody) {
  final Map<String, dynamic> data = jsonDecode(responseBody);
  final List<dynamic> content = data['content'];
  return content
      .map((json) => Recipe.fromJson(json))
      .where((recipe) => recipe.status)
      .toList();
}

class RecipeService {
  RecipeService._privateConstructor();
  static final RecipeService instance = RecipeService._privateConstructor();

  final ValueNotifier<List<Recipe>?> myRecipesNotifier = ValueNotifier(null);
  final ValueNotifier<List<Recipe>?> recentImportsNotifier = ValueNotifier(null);
  final ValueNotifier<List<Recipe>?> homeSuggestionsNotifier = ValueNotifier(null);
  
  // Cache for explore data
  final Map<String, dynamic> _cache = {};

  static const String _persistentCachePrefix = 'persistent_cache_v3_';

  Future<void> _writeToPersistentCache(String key, dynamic data) async {
    await DatabaseService.instance.writeCache('$_persistentCachePrefix$key', data);
  }

  Future<dynamic> _readFromPersistentCache(String key, Duration ttl) async {
    return DatabaseService.instance.readCache('$_persistentCachePrefix$key', ttl);
  }

  Future<void> clearCache() async {
    _cache.clear();
    await DatabaseService.instance.clearCache();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> detectIngredients(XFile image) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/detect-ingredients');
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
      String errorMessage = 'Ingredient detection failed. Please try again.';
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


  Future<Map<String, dynamic>> validateTypedIngredients(List<String> ingredients) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/validate-typed-ingredients');
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
      String errorMessage = 'Validation failed. Please try again.';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}
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
      return await compute(_parseRecipesList, response.body);
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

    // Fast Hive cache load
    if (myRecipesNotifier.value == null) {
      try {
        final cachedStr = DatabaseService.instance.readCacheRaw('my_recipes_cache_v3');
        if (cachedStr != null) {
          final List<dynamic> data = jsonDecode(cachedStr);
          myRecipesNotifier.value = data.map((json) => Recipe.fromJson(json)).toList();
        }
      } catch (e) {
        debugPrint('Failed to load recipe cache: $e');
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final recipes = await compute(_parseRecipesList, response.body);
      myRecipesNotifier.value = recipes;
      
      try {
        await DatabaseService.instance.writeCacheRaw('my_recipes_cache_v3', response.body);
      } catch (_) {}

      return recipes;
    } else {
      if (myRecipesNotifier.value != null) return myRecipesNotifier.value!;
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
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(seconds: 15));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList
            .map((json) => Recipe.fromJson(json))
            .where((recipe) => recipe.status)
            .toList();
        results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
      final results = await compute(_parseExploreRecipesData, response.body);
      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      if (forceRefresh) {
        for (final recipe in results) {
          final imageUrl = recipe.image;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            try {
              CachedNetworkImageProvider(imageUrl).evict().catchError((_) => false);
            } catch (_) {}
          }
        }
      }

      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await _writeToPersistentCache(cacheKey, data['content']);
      } catch (_) {}
      
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
      final results = await compute(_parseRecipesList, response.body);
      
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
    
    final String? existingJson = DatabaseService.instance.readCacheRaw(_tempSuggestionsKey);
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
        categories: r.categories,
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
    await DatabaseService.instance.writeCacheRaw(_tempSuggestionsKey, jsonEncode(current.map((r) => r.toJson()).toList()));
    
    // Refresh notifier if already has data
    if (homeSuggestionsNotifier.value != null) {
      await getHomeSuggestions(forceRefresh: true);
    }
  }

  Future<void> _removeTemporarySuggestion(String name) async {
    final String? existingJson = DatabaseService.instance.readCacheRaw(_tempSuggestionsKey);
    if (existingJson == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(existingJson);
      final List<Recipe> local = decoded.map((j) => Recipe.fromJson(j)).toList();
      final filtered = local.where((r) => r.name.toLowerCase() != name.toLowerCase()).toList();
      
      if (filtered.length != local.length) {
        await DatabaseService.instance.writeCacheRaw(_tempSuggestionsKey, jsonEncode(filtered.map((r) => r.toJson()).toList()));
        if (homeSuggestionsNotifier.value != null) {
          await getHomeSuggestions(forceRefresh: true);
        }
      }
    } catch (_) {}
  }

  Future<List<Recipe>> _mergeTemporarySuggestions(List<Recipe> backendResults) async {
    final String? existingJson = DatabaseService.instance.readCacheRaw(_tempSuggestionsKey);
    if (existingJson == null) return backendResults;

    try {
      final List<dynamic> decoded = jsonDecode(existingJson);
      final List<Recipe> local = decoded.map((j) => Recipe.fromJson(j)).toList();
      
      final now = DateTime.now();
      // Filter out expired ones
      final validLocal = local.where((r) => r.expiresAt != null && r.expiresAt!.isAfter(now)).toList();
      
      // If some expired, update storage
      if (validLocal.length != local.length) {
        await DatabaseService.instance.writeCacheRaw(_tempSuggestionsKey, jsonEncode(validLocal.map((r) => r.toJson()).toList()));
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
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(seconds: 15));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        return results;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/explore/cuisines');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final results = data.map((item) => Map<String, dynamic>.from(item)).toList();

      if (forceRefresh) {
        for (final item in results) {
          final imageUrl = item['image'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            try {
              CachedNetworkImageProvider(imageUrl).evict().catchError((_) => false);
            } catch (_) {}
          }
        }
      }

      await _writeToPersistentCache(cacheKey, results);
      return results;
    } else {
      throw Exception('Unable to load cuisines.');
    }
  }

  Future<List<Map<String, dynamic>>> getExploreCategories({bool forceRefresh = false}) async {
    const cacheKey = 'explore_categories';
    if (!forceRefresh) {
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(seconds: 15));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
        return results;
      }
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/explore/categories');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final results = data.map((item) => Map<String, dynamic>.from(item)).toList();

      if (forceRefresh) {
        for (final item in results) {
          final imageUrl = item['image'] as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            try {
              CachedNetworkImageProvider(imageUrl).evict().catchError((_) => false);
            } catch (_) {}
          }
        }
      }

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
      final cachedData = await _readFromPersistentCache(cacheKey, const Duration(seconds: 15));
      if (cachedData != null) {
        final List<dynamic> decodedList = cachedData;
        final results = decodedList
            .map((json) => Recipe.fromJson(json))
            .where((recipe) => recipe.status)
            .toList();
        results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
      final results = await compute(_parseExploreRecipesData, response.body);
      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      if (forceRefresh) {
        for (final recipe in results) {
          final imageUrl = recipe.image;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            try {
              CachedNetworkImageProvider(imageUrl).evict().catchError((_) => false);
            } catch (_) {}
          }
        }
      }

      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await _writeToPersistentCache(cacheKey, data['content']);
      } catch (_) {}
      
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
      final recipes = await compute(_parseExploreRecipesData, response.body);
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
