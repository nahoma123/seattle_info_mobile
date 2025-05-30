// lib/src/features/listings/domain/listing.dart
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'listing_details_models.dart'; // Import the detail models

// Helper for robust date parsing
DateTime? _parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateTime.tryParse(dateString);
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing date for Listing: $dateString, Error: $e');
    }
    return null;
  }
}

class Listing {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String userId; // User who posted
  final double? price;
  final String status; // e.g., "active", "expired", "pending_approval"
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  // Contact details - these might be conditionally available based on auth
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? zipCode;

  // Category-specific details
  final HousingDetails? housingDetails;
  final BabysittingDetails? babysittingDetails;
  // Add other specific details like EventDetails if needed

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.userId,
    this.price,
    required this.status,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.addressLine1,
    this.city,
    this.state,
    this.zipCode,
    this.housingDetails,
    this.babysittingDetails,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as String,
      userId: json['user_id'] as String,
      price: (json['price'] as num?)?.toDouble(),
      status: json['status'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
      expiresAt: _parseDate(json['expires_at'] as String?),
      contactName: json['contact_name'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      addressLine1: json['address_line1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      housingDetails: json['housing_details'] != null
          ? HousingDetails.fromJson(json['housing_details'] as Map<String, dynamic>)
          : null,
      babysittingDetails: json['babysitting_details'] != null
          ? BabysittingDetails.fromJson(json['babysitting_details'] as Map<String, dynamic>)
          : null,
    );
  }

  // toJson method for creating/updating listings
  Map<String, dynamic> toJsonForCreate() {
     // Only include fields relevant for creation. ID, userID, status, timestamps are usually set by backend.
    return {
      'title': title,
      'description': description,
      'category_id': categoryId,
      if (price != null) 'price': price,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (contactName != null) 'contact_name': contactName,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipCode != null) 'zip_code': zipCode,
      if (housingDetails != null) 'housing_details': housingDetails!.toJson(),
      if (babysittingDetails != null) 'babysitting_details': babysittingDetails!.toJson(),
    };
  }
}
