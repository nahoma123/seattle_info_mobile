import 'listing.dart';

// Define a class for query parameters if they become complex
class ListingFilters {
  final String? categoryId;
  final String? userId;
  final String? searchTerm;
  final double? latitude;
  final double? longitude;
  final double? radiusKm; // Default radius can be set by backend if not provided
  final String? sortBy;   // e.g., "distance", "created_at"
  final String? sortOrder; // e.g., "asc", "desc"

  ListingFilters({
    this.categoryId,
    this.userId,
    this.searchTerm,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.sortBy,
    this.sortOrder,
  });

  //copyWith method for easily updating filters
  ListingFilters copyWith({
    String? categoryId,
    String? userId,
    String? searchTerm,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? sortBy,
    String? sortOrder,
    bool clearLocation = false, // Special flag to nullify location
  }) {
    return ListingFilters(
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      searchTerm: searchTerm ?? this.searchTerm,
      latitude: clearLocation ? null : latitude ?? this.latitude,
      longitude: clearLocation ? null : longitude ?? this.longitude,
      radiusKm: clearLocation ? null : radiusKm ?? this.radiusKm,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  // For FutureProvider family key, ensure it's comparable or override == and hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingFilters &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          userId == other.userId &&
          searchTerm == other.searchTerm &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radiusKm == other.radiusKm &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      userId.hashCode ^
      searchTerm.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      radiusKm.hashCode ^
      sortBy.hashCode ^
      sortOrder.hashCode;
}

abstract class ListingRepository {
  Future<List<Listing>> fetchListings(ListingFilters? filters);
  Future<Listing> fetchListingDetails(String id);
  Future<Listing> createListing(Listing listing, String token); // Token for authenticated POST
}
