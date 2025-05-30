import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/listing.dart';
import '../domain/listing_repository.dart';
// TODO: Import a centralized config for base URL. Using placeholder for now.
const String _placeholderBaseUrl = 'http://yourbackendapi.example.com';

class ApiListingRepository implements ListingRepository {
  final http.Client _client;
  final String _baseUrl;

  ApiListingRepository({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _placeholderBaseUrl;

  @override
  Future<List<Listing>> fetchListings(ListingFilters? filters) async {
    var queryParams = <String, String>{
      'page_size': '20', // Default page size
    };
    if (filters != null) {
      if (filters.categoryId != null) queryParams['category_id'] = filters.categoryId!;
      if (filters.userId != null) queryParams['user_id'] = filters.userId!;
      if (filters.searchTerm != null && filters.searchTerm!.isNotEmpty) queryParams['search_term'] = filters.searchTerm!;
      if (filters.latitude != null) queryParams['latitude'] = filters.latitude!.toString();
      if (filters.longitude != null) queryParams['longitude'] = filters.longitude!.toString();
      if (filters.radiusKm != null) queryParams['radius_km'] = filters.radiusKm!.toString();
      if (filters.sortBy != null && filters.sortBy!.isNotEmpty) queryParams['sort_by'] = filters.sortBy!;
      if (filters.sortOrder != null && filters.sortOrder!.isNotEmpty) queryParams['sort_order'] = filters.sortOrder!;
    }

    final uri = Uri.parse('$_baseUrl/api/v1/listings').replace(queryParameters: queryParams);
    try {
      final response = await _client.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> listJson = data['data'] as List<dynamic>;
        return listJson.map((jsonItem) => Listing.fromJson(jsonItem as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load listings: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load listings: $e');
    }
  }

  @override
  Future<Listing> fetchListingDetails(String id) async {
    final uri = Uri.parse('$_baseUrl/api/v1/listings/$id');
    try {
      final response = await _client.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        // The API doc for GET /api/v1/listings/{id} implies it returns the listing object directly, not nested in 'data'.
        // If it IS nested like the list endpoint, this needs: final Map<String, dynamic> data = json.decode(response.body)['data'];
        final Map<String, dynamic> data = json.decode(response.body);
        return Listing.fromJson(data);
      } else {
        throw Exception('Failed to load listing details: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load listing details: $e');
    }
  }

  @override
  Future<Listing> createListing(Listing listing, String token) async {
    final uri = Uri.parse('$_baseUrl/api/v1/listings');
    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(listing.toJsonForCreate()),
      );

      if (response.statusCode == 201) { // 201 Created
        final Map<String, dynamic> data = json.decode(response.body);
        return Listing.fromJson(data);
      } else {
        // Attempt to parse error body for more specific messages
        String errorMessage = 'Failed to create listing: ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          // Example: Backend might send { "code": "FIRST_POST_LIMIT_REACHED", "message": "Your first post is pending..." }
          // Or just { "message": "..." }
          final serverMessage = errorData['message'] as String?;
          final errorCode = errorData['code'] as String?;

          if (errorCode == 'FIRST_POST_LIMIT_REACHED' ||
              errorCode == 'FIRST_POST_PENDING_APPROVAL' || // Add known codes
              serverMessage?.toLowerCase().contains('first post') == true ||
              serverMessage?.toLowerCase().contains('moderation') == true) {
            errorMessage = serverMessage ?? 'Your first post is pending approval. You can post more once it is approved.';
          } else if (serverMessage != null && serverMessage.isNotEmpty) {
            errorMessage = serverMessage;
          } else {
            errorMessage = '${errorMessage} ${response.body}';
          }
        } catch (e) {
          // Failed to parse error body, use generic response body
          errorMessage = '${errorMessage} ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Catch network errors or other exceptions not from HTTP response
      // If e is already an Exception with our specific message, rethrow it.
      // Otherwise, wrap it.
      if (e is Exception && (e.toString().contains("FIRST_POST_LIMIT_REACHED") || e.toString().contains("FIRST_POST_PENDING_APPROVAL") || e.toString().toLowerCase().contains('first post') || e.toString().toLowerCase().contains('moderation'))) {
        rethrow;
      }
      throw Exception('Failed to create listing: $e');
    }
  }
}
