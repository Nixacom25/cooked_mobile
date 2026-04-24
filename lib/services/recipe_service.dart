import 'dart:convert';
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
      throw Exception('Failed to generate recipes. Please try again.');
    }
  }

  Future<List<Recipe>> getMyRecipes() async {
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
        'kcal': recipe.kcal,
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
        'sourceUrl': recipe.sourceUrl,
        'cookbookIds': cookbookIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Trigger background refresh of recipes list
      getMyRecipes().then((_) => null).catchError((_) => null);
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to save recipe: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to save recipe: ${response.body}');
    }
  }

  Future<void> toggleFavorite(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/favorite');
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Unable to change favorite status.');
    }

    // Refresh local state in background
    getMyRecipes().then((_) => null).catchError((_) => null);
    getFavoriteRecipes(size: 100).then((_) => null).catchError((_) => null);
  }

  Future<List<Recipe>> getExploreRecipes({int page = 0, int size = 10}) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/explore?page=$page&size=$size',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Unable to load explore recipes.');
    }
  }

  Future<List<Recipe>> getFavoriteRecipes({int page = 0, int size = 10}) async {
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
    int page = 0,
    int size = 10,
  }) async {
    final categoryParam = category != null ? '&category=$category' : '';
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/popular?page=$page&size=$size$categoryParam',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Recipe.fromJson(json)).toList();
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
      getMyRecipes().then((_) => null).catchError((_) => null);
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Import failed';
      throw Exception(error);
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

  Future<List<Map<String, dynamic>>> searchWeb(String query) async {
    final endpoint = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/web-search?query=${Uri.encodeComponent(query)}',
    );
    final response = await http.get(endpoint, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Web search failed');
    }
  }

  Future<List<Recipe>> getRecentImports({int page = 0, int size = 6}) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/recipes/imports?page=$page&size=$size',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => Recipe.fromJson(json)).toList();
    } else {
      throw Exception('Unable to load recent imports.');
    }
  }

  Future<Recipe> validateRecipe(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/recipes/$id/validate');
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      // Trigger background refresh 
      getMyRecipes().then((_) => null).catchError((_) => null);
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to validate recipe.');
    }
  }

  void clearData() {
    myRecipesNotifier.value = null;
    favoriteRecipesNotifier.value = null;
  }
}
