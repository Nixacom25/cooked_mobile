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

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Cookbook>> getMyCookbooks() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final cookbooks = data.map((json) => Cookbook.fromJson(json)).toList();
      myCookbooksNotifier.value = cookbooks;
      return cookbooks;
    } else {
      throw Exception('Unable to load your cookbooks.');
    }
  }

  Future<Cookbook> getCookbook(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return Cookbook.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Unable to load the cookbook.');
    }
  }

  Future<Cookbook> createCookbook(String name, List<String> recipeIds) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'recipeIds': recipeIds}),
    );

    if (response.statusCode == 200) {
      getMyCookbooks().then((_) => null).catchError((_) => null);
      return Cookbook.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Unable to create cookbook.');
    }
  }

  Future<Cookbook> updateCookbook(
    String id,
    String name,
    List<String> recipeIds,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'name': name, 'recipeIds': recipeIds}),
    );

    if (response.statusCode == 200) {
      getMyCookbooks().then((_) => null).catchError((_) => null);
      return Cookbook.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Unable to update cookbook.');
    }
  }

  Future<void> deleteCookbook(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/cookbooks/$id');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Unable to delete cookbook.');
    }
    getMyCookbooks().catchError((_) => <Cookbook>[]);
  }

  Future<Cookbook> addRecipeToCookbook(
    String cookbookId,
    String recipeId,
  ) async {
    final cb = await getCookbook(cookbookId);
    final ids = cb.recipes.map((r) => r.id).toList();
    if (!ids.contains(recipeId)) {
      ids.add(recipeId);
      return updateCookbook(cookbookId, cb.name, ids);
    }
    return cb;
  }
}
