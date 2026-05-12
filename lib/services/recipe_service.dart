import 'dart:convert';
import 'dart:async';
import 'package:cooked/services/cookbook_service.dart';
import 'package:cooked/services/history_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/api_config.dart';
import '../models/recipe.dart';
import '../models/creator.dart';
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

class RecipeService {
  RecipeService._privateConstructor();
  static final RecipeService instance = RecipeService._privateConstructor();

  final ValueNotifier<List<Recipe>?> myRecipesNotifier = ValueNotifier(null);
  final ValueNotifier<List<Recipe>?> favoriteRecipesNotifier = ValueNotifier(
    null,
  );
  final ValueNotifier<List<Recipe>?> recentImportsNotifier = ValueNotifier(null);
  final ValueNotifier<List<Recipe>?> homeSuggestionsNotifier = ValueNotifier(null);
  
  // Cache for explore data
  final Map<String, dynamic> _cache = {};

  // Debouncing for favorites
  final Map<String, Timer> _favoriteDebouncers = {};
  final Map<String, bool> _originalFavoriteStates = {};

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
        );
        myRecipesNotifier.value = [placeholder, ...myRecipesNotifier.value!];
      }

      // Trigger background refresh 
      await getMyRecipes(forceRefresh: true);
      await getRecentImports(forceRefresh: true);
      CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
      return saved;
    } else {
      print('Failed to save recipe: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to save recipe: ${response.body}');
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (id.isEmpty) {
      debugPrint('RecipeService: Cannot toggle favorite for empty recipe ID');
      return;
    }

    // 1. Optimistic local update
    _updateLocalFavoriteStatus(id);

    // 2. Debounce backend call (5s delay)
    _favoriteDebouncers[id]?.cancel();
    _favoriteDebouncers[id] = Timer(const Duration(seconds: 5), () async {
      final currentIsFav = _getCurrentIsFavorite(id);
      final originalIsFav = _originalFavoriteStates[id];

      // Only send to backend if the final state is different from the original
      if (originalIsFav != null && currentIsFav != originalIsFav) {
        try {
          final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/favorite');
          final response = await http.put(url, headers: await _getHeaders());

          if (response.statusCode == 200) {
            // Silently refresh in background to ensure full sync
            getFavoriteRecipes(size: 100, forceRefresh: true).then((_) => null).catchError((_) => null);
            getMyRecipes(forceRefresh: true).then((_) => null).catchError((_) => null);
            CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
          }
        } catch (e) {
          debugPrint('Error syncing favorite state for $id: $e');
        }
      }

      _favoriteDebouncers.remove(id);
      _originalFavoriteStates.remove(id);
    });
  }

  void _updateLocalFavoriteStatus(String id) {
    bool foundInAny = false;

    void toggleInList(ValueNotifier<List<Recipe>?> notifier) {
      if (notifier.value == null) return;
      bool changed = false;
      final newList = notifier.value!.map((r) {
        if (r.id == id) {
          if (!foundInAny) {
            // First time we see it in this toggle sequence, remember original state
            if (!_originalFavoriteStates.containsKey(id)) {
              _originalFavoriteStates[id] = r.isFavorite;
            }
            foundInAny = true;
          }
          r.isFavorite = !r.isFavorite;
          changed = true;
        }
        return r;
      }).toList();
      if (changed) {
        notifier.value = newList;
      }
    }

    // Toggle in all major notifiers
    toggleInList(myRecipesNotifier);
    toggleInList(favoriteRecipesNotifier);
    toggleInList(recentImportsNotifier);
    toggleInList(homeSuggestionsNotifier);
    
    // Also check history service if available
    final historyList = HistoryService.instance.recentlyViewedNotifier.value;
    if (historyList.isNotEmpty) {
      bool changed = false;
      final newHistory = historyList.map((r) {
        if (r.id == id) {
          if (!foundInAny) {
            if (!_originalFavoriteStates.containsKey(id)) {
              _originalFavoriteStates[id] = r.isFavorite;
            }
            foundInAny = true;
          }
          r.isFavorite = !r.isFavorite;
          changed = true;
        }
        return r;
      }).toList();
      if (changed) {
        HistoryService.instance.recentlyViewedNotifier.value = newHistory;
      }
    }
  }

  bool _getCurrentIsFavorite(String id) {
    // Check in any notifier to get the current UI state
    final all = [
      myRecipesNotifier.value,
      favoriteRecipesNotifier.value,
      homeSuggestionsNotifier.value,
      HistoryService.instance.recentlyViewedNotifier.value,
    ];
    for (var list in all) {
      if (list == null) continue;
      for (var r in list) {
        if (r.id == id) return r.isFavorite;
      }
    }
    return false;
  }

  Future<List<Recipe>> getExploreRecipes({String? cuisine, String? category, int page = 0, int size = 10, bool forceRefresh = false}) async {
    final cacheKey = 'explore_recipes_${cuisine ?? ''}_${category ?? ''}_${page}_${size}';
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<Recipe>;
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
      _cache[cacheKey] = results;
      homeSuggestionsNotifier.value = results;
      return results;
    } else {
      throw Exception('Unable to load home suggestions.');
    }
  }

  Future<Map<String, int>> getExploreCuisines({bool forceRefresh = false}) async {
    const cacheKey = 'explore_cuisines';
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Map<String, int>;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/explore/cuisines');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final results = data.cast<String, int>();
      _cache[cacheKey] = results;
      return results;
    } else {
      throw Exception('Unable to load cuisines.');
    }
  }

  Future<Map<String, int>> getExploreCategories({bool forceRefresh = false}) async {
    const cacheKey = 'explore_categories';
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Map<String, int>;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/explore/categories');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final results = data.cast<String, int>();
      _cache[cacheKey] = results;
      return results;
    } else {
      throw Exception('Unable to load categories.');
    }
  }

  Future<List<Recipe>> getFavoriteRecipes({int page = 0, int size = 10, bool forceRefresh = false}) async {
    if (!forceRefresh && page == 0 && favoriteRecipesNotifier.value != null) {
      return favoriteRecipesNotifier.value!;
    }
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/favorites?page=$page&size=$size',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      final recipes = content.map((json) => Recipe.fromJson(json)).toList();

      // Update global notifier if we query a large enough chunk (like in ViewAllScreen)
      if (size >= 50 || page == 0) {
        favoriteRecipesNotifier.value = recipes;
      }

      return recipes;
    } else {
      throw Exception('Unable to load favorite recipes.');
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
    final cacheKey = 'popular_recipes_${category ?? ''}_${cuisine ?? ''}_${page}_${size}';
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<Recipe>;
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
    final response = await http.get(endpoint, headers: await _getHeaders());

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

  Future<Recipe> validateRecipe(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/validate');
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final validated = Recipe.fromJson(jsonDecode(response.body));
      
      // Refresh list without full skeleton
      await getMyRecipes(forceRefresh: true);
      CookbookService.instance.getMyCookbooks(forceRefresh: true).then((_) => null).catchError((_) => null);
      return validated;
    } else {
      throw Exception('Failed to validate recipe.');
    }
  }

  void clearData() {
    myRecipesNotifier.value = null;
    favoriteRecipesNotifier.value = null;
    recentImportsNotifier.value = null;
    homeSuggestionsNotifier.value = null;
  }
}
