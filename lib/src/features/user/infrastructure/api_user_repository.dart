import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/app_user.dart';
import '../domain/user_repository.dart';

class ApiUserRepository implements UserRepository {
  final http.Client _client;
  // TODO: Replace with actual base URL from config
  final String _baseUrl = 'YOUR_BACKEND_API_BASE_URL'; // e.g., http://localhost:8080 or https://api.seattleinfo.com

  ApiUserRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<AppUser> fetchUserDetails(String token) async {
    final uri = Uri.parse('$_baseUrl/api/v1/auth/me');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Assuming the actual user data is nested under a 'data' key,
        // similar to other API responses. If /auth/me returns the user object directly at the root, adjust this.
        // Based on the provided API Doc for /api/v1/auth/me, it's at the root.
        return AppUser.fromJson(data);
      } else {
        // Consider more specific error handling based on status codes
        print('ApiUserRepository Error: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load user details: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('ApiUserRepository Exception: $e');
      throw Exception('Failed to load user details: $e');
    }
  }
}
