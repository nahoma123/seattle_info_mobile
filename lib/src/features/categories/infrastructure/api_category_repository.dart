import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/category.dart';
import '../domain/category_repository.dart';
// TODO: Import a centralized config for base URL in a future step.
// For now, hardcoding a placeholder. Replace 'YOUR_BACKEND_API_BASE_URL'
// with the actual base URL when available.
const String _placeholderBaseUrl = 'http://yourbackendapi.example.com';


class ApiCategoryRepository implements CategoryRepository {
  final http.Client _client;
  final String _baseUrl;

  ApiCategoryRepository({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _placeholderBaseUrl;

  @override
  Future<List<Category>> fetchCategories() async {
    // The API is paginated. For now, fetching with a large page size to get all.
    // A more robust solution would handle actual pagination.
    final uri = Uri.parse('$_baseUrl/api/v1/categories?page_size=100'); // Fetch up to 100 categories
    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // According to API doc, categories are in a 'data' list
        final List<dynamic> categoryListJson = data['data'] as List<dynamic>;
        return categoryListJson.map((jsonItem) => Category.fromJson(jsonItem as Map<String, dynamic>)).toList();
      } else {
        print('ApiCategoryRepository Error fetching categories: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiCategoryRepository Exception fetching categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
}
