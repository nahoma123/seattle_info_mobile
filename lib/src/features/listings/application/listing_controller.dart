import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart'; // To get token for create
import '../domain/listing.dart';
import '../domain/listing_repository.dart';
import '../infrastructure/api_listing_repository.dart';

// Provider for ListingRepository
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ApiListingRepository(); // Consider injecting client and baseUrl
});

// Provider to fetch listings with optional filters
// This might be better as a FamilyAsyncNotifierProvider if filters are dynamic from UI
final listingsProvider = FutureProvider.autoDispose.family<List<Listing>, ListingFilters?>((ref, filters) async {
  final listingRepository = ref.watch(listingRepositoryProvider);
  return listingRepository.fetchListings(filters);
});

// Provider to fetch single listing details
final listingDetailsProvider = FutureProvider.autoDispose.family<Listing, String>((ref, id) async {
   final listingRepository = ref.watch(listingRepositoryProvider);
   return listingRepository.fetchListingDetails(id);
});

// StateNotifier for creating listings (example)
class CreateListingController extends StateNotifier<AsyncValue<Listing?>> {
  final ListingRepository _listingRepository;
  final String? _authToken; // This will be passed via provider dependency or method

  CreateListingController(this._listingRepository, this._authToken) : super(const AsyncValue.data(null));

  Future<bool> createListing(Listing listing, String token) async { // Token passed here
    state = const AsyncValue.loading();
    try {
      final createdListing = await _listingRepository.createListing(listing, token);
      state = AsyncValue.data(createdListing);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final createListingControllerProvider = StateNotifierProvider.autoDispose<CreateListingController, AsyncValue<Listing?>>((ref) {
  final listingRepository = ref.watch(listingRepositoryProvider);
  // The token is not stored in the controller state anymore.
  // It should be fetched and passed to the `createListing` method when called from the UI.
  // Example:
  // String? token = await ref.read(authControllerProvider.notifier).getCurrentUserToken();
  // if (token != null) {
  //   ref.read(createListingControllerProvider.notifier).createListing(myListing, token);
  // }
  return CreateListingController(listingRepository, null); // Token is not pre-fetched into controller state.
});

// Note on token handling for CreateListingController:
// The previous example of trying to get token via ref.watch(authStateChangesProvider) in the provider
// itself is problematic for actions like 'create' because:
// 1. authStateChangesProvider provides a stream, and you need a specific token at a point in time.
// 2. firebaseUser.getIdToken() is async, and providers should not be async in their creation if avoidable.
//
// The corrected approach is:
// - The `CreateListingController.createListing` method now explicitly accepts a `token`.
// - The UI/calling code is responsible for fetching the token (e.g., using `ref.read(authControllerProvider.notifier).getCurrentUserToken()`)
//   and then passing it to the `createListing` method.
// - The `createListingControllerProvider` no longer tries to pre-fetch or store the token.
//   The `_authToken` field in `CreateListingController` is now `null` from the provider,
//   and the actual token is supplied per-call to the `createListing` method.
//   (The `_authToken` field in `CreateListingController` could be removed if not used for other methods).
//   For this subtask, we'll keep `_authToken` as null to signify it's not being managed by the provider directly.
//   The important part is that `createListing` method in `CreateListingController` takes `token` as argument.
