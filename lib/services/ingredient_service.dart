import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';

class IngredientService {
  static final IngredientService instance = IngredientService._();
  IngredientService._();

  Future<List<Map<String, dynamic>>> getSavedIngredients() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/saved'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<bool> saveIngredient(String name, {String icon = "🥕"}) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/saved'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'icon': icon,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> unsaveIngredient(String id) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/saved/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }
 
  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return [];
 
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/search?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
 
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getRecentIngredients() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ingredients/recent'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }
}
