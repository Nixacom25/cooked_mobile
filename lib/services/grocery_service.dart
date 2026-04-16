import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/grocery_item.dart';
import 'auth_service.dart';

class GroceryService {
  GroceryService._privateConstructor();
  static final GroceryService instance = GroceryService._privateConstructor();

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<GroceryItem>> getMyGroceries() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GroceryItem.fromJson(json)).toList();
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
      return GroceryItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add item to grocery list.');
    }
  }

  Future<GroceryItem> toggleBought(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/$id/toggle');
    final response = await http.put(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return GroceryItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to toggle item status.');
    }
  }

  Future<void> deleteGroceryItem(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/grocery-items/$id');
    final response = await http.delete(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete grocery item.');
    }
  }
}
