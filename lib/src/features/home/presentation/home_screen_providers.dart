import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../listings/domain/listing_repository.dart'; // For ListingFilters

// This will hold the current filter state for the home screen
final homeScreenFiltersProvider = StateProvider<ListingFilters>((ref) {
  // Initial filters: sort by created_at desc by default
  return ListingFilters(sortBy: 'created_at', sortOrder: 'desc');
});
