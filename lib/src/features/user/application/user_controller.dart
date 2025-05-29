import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_controller.dart'; // To get token
import '../domain/app_user.dart';
import '../domain/user_repository.dart';
import '../infrastructure/api_user_repository.dart';

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // In a real app, http.Client might be provided by another provider
  return ApiUserRepository();
});

// This provider will supply the AppUser details.
// It depends on the auth state; if logged in, it fetches user details.
final userDetailsProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateChangesProvider); // From your auth_controller.dart
  final firebaseUser = authState.asData?.value;

  if (firebaseUser == null) {
    // Not logged in, so no user details to fetch
    return null;
  }

  try {
    final token = await firebaseUser.getIdToken();
    if (token == null) {
      throw Exception('Could not retrieve Firebase ID token.');
    }
    final userRepository = ref.watch(userRepositoryProvider);
    return await userRepository.fetchUserDetails(token);
  } catch (e, st) {
    // Handle error fetching user details (e.g., network error, token issue)
    print('Error fetching AppUser details: $e\n$st');
    // Optionally, sign out the user if token is invalid or other critical auth error
    // ref.read(authControllerProvider.notifier).signOut();
    return null; // Or rethrow to show error in UI
  }
});
