import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/listings/presentation/listing_detail_screen.dart';
import '../features/listings/presentation/create_listing_screen.dart'; // Added
// Import user_controller if needed for redirection logic based on AppUser details
// import '../features/user/application/user_controller.dart';

// Provider to expose the GoRouter instance
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  // final appUserAsyncValue = ref.watch(userDetailsProvider); // If needed for deeper inspection

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true, // Enable for development
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/listing/:id', // Use :id for path parameter
        builder: (context, state) {
          final listingId = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: listingId);
        },
      ),
     GoRoute(
       path: '/create-listing',
       builder: (context, state) => const CreateListingScreen(),
     ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final bool loggingIn = state.matchedLocation == '/login';
      final bool splashing = state.matchedLocation == '/splash';

      // If on splash, and auth state is determined, redirect accordingly
      if (splashing) {
        if (authState is AsyncLoading) return null; // Stay on splash while loading
        return loggedIn ? '/home' : '/login';
      }

      // If not logged in and not trying to log in, redirect to /login
      if (!loggedIn && !loggingIn) {
        return '/login';
      }

      // If logged in and trying to access /login, redirect to /home
      if (loggedIn && loggingIn) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    // refreshListenable: GoRouterRefreshStream(authStateChangesProvider.stream), // Alternative way to trigger redirect
  );
});

// Helper class for GoRouter to listen to a stream for changes.
// class GoRouterRefreshStream extends ChangeNotifier {
//   GoRouterRefreshStream(Stream<dynamic> stream) {
//     notifyListeners();
//     _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
//   }
//   late final StreamSubscription<dynamic> _subscription;
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }
