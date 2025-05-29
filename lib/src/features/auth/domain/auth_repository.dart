import 'package:firebase_auth/firebase_auth.dart' show User; // Specifically import User

abstract class AuthRepository {
  Future<User?> signUpWithEmailPassword(String email, String password);
  Future<User?> signInWithEmailPassword(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<void> signOut();
  Stream<User?> authStateChanges();
  Future<String?> getCurrentUserToken();
  User? getCurrentUser();
}
