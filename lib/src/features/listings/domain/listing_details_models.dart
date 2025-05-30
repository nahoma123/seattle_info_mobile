// lib/src/features/listings/domain/listing_details_models.dart
class HousingDetails {
  final String? propertyType; // e.g., "for_rent", "for_sale"
  final String? rentDetails;  // e.g., "2-bedroom, 1-bath, 1000sqft"

  HousingDetails({this.propertyType, this.rentDetails});

  factory HousingDetails.fromJson(Map<String, dynamic> json) {
    return HousingDetails(
      propertyType: json['property_type'] as String?,
      rentDetails: json['rent_details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (propertyType != null) 'property_type': propertyType,
      if (rentDetails != null) 'rent_details': rentDetails,
    };
  }
}

class BabysittingDetails {
  final List<String>? languagesSpoken;

  BabysittingDetails({this.languagesSpoken});

  factory BabysittingDetails.fromJson(Map<String, dynamic> json) {
    return BabysittingDetails(
      languagesSpoken: (json['languages_spoken'] as List<dynamic>?)
          ?.map((lang) => lang as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (languagesSpoken != null) 'languages_spoken': languagesSpoken,
    };
  }
}
