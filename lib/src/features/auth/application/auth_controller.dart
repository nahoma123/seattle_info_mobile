import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_repository.dart';
import '../infrastructure/firebase_auth_repository.dart'; // Assuming you have a way to provide this

// Provider for the AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(); // Ideally, dependencies like FirebaseAuth would be injected
});

// Provider for exposing the stream of authentication state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

// StateNotifier for AuthController (manages auth state and actions)
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;
  
  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncValue.loading()) {
    // Check initial auth state or listen to changes
    _authRepository.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });
    // Or get current user initially
    // final initialUser = _authRepository.getCurrentUser();
    // state = AsyncValue.data(initialUser);
  }

  User? get currentUser => _authRepository.getCurrentUser();
  
  Future<void> signInWithEmailPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithEmailPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpWithEmailPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithApple();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> getCurrentUserToken() {
    return _authRepository.getCurrentUserToken();
  }
}

// Provider for the AuthController
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});
