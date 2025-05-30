import 'package:flutter/foundation.dart'; // For kDebugMode

// Helper for robust date parsing
DateTime? _parseDate(String? dateString) {
  if (dateString == null) return null;
  try {
    return DateTime.tryParse(dateString);
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing date for Category: $dateString, Error: $e');
    }
    return null;
  }
}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Subcategories are not included in the base model for now as per API spec for /api/v1/categories

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      createdAt: _parseDate(json['created_at'] as String?),
      updatedAt: _parseDate(json['updated_at'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

 @override
 bool operator ==(Object other) =>
     identical(this, other) ||
     other is Category &&
         runtimeType == other.runtimeType &&
         id == other.id &&
         name == other.name &&
         slug == other.slug;

 @override
 int get hashCode => id.hashCode ^ name.hashCode ^ slug.hashCode;

 @override
 String toString() {
   return 'Category{id: $id, name: $name, slug: $slug}';
 }
}
