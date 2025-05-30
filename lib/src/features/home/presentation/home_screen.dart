import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator
import '../../auth/application/auth_controller.dart';
import '../../categories/application/category_controller.dart';
import '../../categories/domain/category.dart'; // For Category type (if used in this file, else can be removed if only for type hint)
import '../../listings/application/listing_controller.dart';
import '../../listings/domain/listing.dart'; // For Listing type
import '../../listings/domain/listing_repository.dart'; // For ListingFilters
import 'home_screen_providers.dart'; // Import the new providers file

class HomeScreen extends ConsumerStatefulWidget { // Changed to StatefulWidget for search controller
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize search text if there's an existing search term in filters
    // Use WidgetsBinding.instance.addPostFrameCallback to safely read provider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Ensure widget is still mounted
        final initialSearchTerm = ref.read(homeScreenFiltersProvider).searchTerm;
        if (initialSearchTerm != null) {
          _searchController.text = initialSearchTerm;
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationAndApplyFilter() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      ref.read(homeScreenFiltersProvider.notifier).update((state) =>
          state.copyWith(latitude: position.latitude, longitude: position.longitude, radiusKm: 10, sortBy: 'distance', sortOrder: 'asc')); // Default radius and sort by distance
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final currentFilters = ref.watch(homeScreenFiltersProvider);
    final listingsAsyncValue = ref.watch(listingsProvider(currentFilters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seattle Info Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/create-listing');
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Listing',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(categoriesProvider);
          // When refreshing, we use the currentFilters that might include search, location, etc.
          ref.invalidate(listingsProvider(currentFilters));
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search listings...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    // Also clear the location filter when clearing search, or provide separate clear for location
                    ref.read(homeScreenFiltersProvider.notifier).update((state) => state.copyWith(searchTerm: '', clearLocation: true, sortBy: 'created_at', sortOrder: 'desc'));
                  },
                )
              ),
              onSubmitted: (value) {
                ref.read(homeScreenFiltersProvider.notifier).update((state) => state.copyWith(searchTerm: value));
              },
            ),
            const SizedBox(height: 10),
            // Location and Sort Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('Use My Location'),
                  onPressed: _fetchLocationAndApplyFilter,
                ),
                // Sort Dropdown
                DropdownButton<String>(
                  value: currentFilters.sortBy ?? 'created_at', // Default to 'created_at'
                  hint: const Text("Sort By"),
                  items: const [
                    DropdownMenuItem(value: 'created_at', child: Text('Latest First')),
                    DropdownMenuItem(value: 'distance', child: Text('Nearest First')),
                    // Add other sort options like price_asc, price_desc if API supports
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final newSortOrder = (value == 'distance') ? 'asc' : 'desc';
                       // If sorting by distance, ensure location is available or prompt user
                      if (value == 'distance' && (currentFilters.latitude == null || currentFilters.longitude == null)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enable location to sort by distance.'))
                        );
                        // Optionally, trigger location fetch or do nothing
                        return;
                      }
                      ref.read(homeScreenFiltersProvider.notifier).update((state) => state.copyWith(sortBy: value, sortOrder: newSortOrder));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Categories Section
            const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            categoriesAsyncValue.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Text('No categories found.');
                }
                return SizedBox(
                  height: 50, // Adjust height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ActionChip( // Changed to ActionChip for better semantics
                          label: Text(category.name),
                          onPressed: () {
                             // Apply category filter, reset search term and location for clarity
                            ref.read(homeScreenFiltersProvider.notifier).update((state) =>
                              state.copyWith(categoryId: category.id, searchTerm: '', clearLocation: true, sortBy: 'created_at', sortOrder: 'desc'));
                             _searchController.clear(); // Clear search bar text
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading categories: $err'),
            ),
            const SizedBox(height: 20),
            // Listings Section
            const Text('Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            listingsAsyncValue.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return const Center(child: Text('No listings found for the current filters.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(listing.title),
                        subtitle: Text(
                          '${listing.description.isNotEmpty ? listing.description.substring(0, listing.description.length > 50 ? 50 : listing.description.length) : ''}...'
                          '\nPrice: \$${listing.price?.toStringAsFixed(2) ?? 'N/A'}',
                        ),
                        onTap: () {
                          context.go('/listing/${listing.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading listings: $err'),
            ),
          ],
        ),
      ),
    );
  }
}
