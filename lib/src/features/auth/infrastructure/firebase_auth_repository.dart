import 'dart:convert'; // For utf8 encoding
import 'package:crypto/crypto.dart'; // For sha256
import 'dart:math'; // For random string generation

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider; // Hide to avoid conflict if you were to use it directly
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../domain/auth_repository.dart';

// Helper Functions for Nonce
// Generates a cryptographically secure random string for the nonce.
String _generateRandomString([int length = 32]) {
  final random = Random.secure();
  final values = List<int>.generate(length, (i) => random.nextInt(256));
  return base64Url.encode(values); // base64Url is safe for HTTP headers and other uses
}

// Creates a SHA-256 hash of the given input string.
String _sha256Hash(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  // final SignInWithApple _signInWithApple; // Apple sign in can be complex to set up fully without testing on device

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    // SignInWithApple? signInWithApple
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();
       // _signInWithApple = signInWithApple ?? SignInWithApple(); // Placeholder

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<String?> getCurrentUserToken() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return await currentUser.getIdToken();
  }

  @override
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors, e.g., e.code == 'user-not-found'
      print('FirebaseAuthException on signIn: ${e.message}');
      return null;
    } catch (e) {
      print('Generic exception on signIn: $e');
      return null;
    }
  }

  @override
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors, e.g., e.code == 'email-already-in-use'
      print('FirebaseAuthException on signUp: ${e.message}');
      return null;
    } catch (e) {
      print('Generic exception on signUp: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut(); // Also sign out from Google
    // Potentially add Apple sign out if implemented
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException on Google signIn: ${e.message}');
      return null;
    } catch (e) {
      print('Generic exception on Google signIn: $e');
      return null;
    }
  }

  @override
  Future<User?> signInWithApple() async {
    print('Attempting Sign in with Apple...');
    try {
      // 1. Generate original nonce
      final originalNonce = _generateRandomString();
      // 2. Hash the original nonce
      final hashedNonce = _sha256Hash(originalNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce, // Pass the hashed nonce to Apple
        // webAuthenticationOptions for web if you configure it:
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: 'YOUR_SERVICE_ID_FROM_APPLE_DEVELOPER_CONSOLE',
        //   redirectUri: Uri.parse('YOUR_WEB_REDIRECT_URI_CONFIGURED_IN_FIREBASE_AND_APPLE'),
        // ),
      );

      final OAuthCredential oauthCredential = OAuthCredential(
        providerId: AppleAuthProvider.PROVIDER_ID,
        signInMethod: AppleAuthProvider.APPLE_SIGN_IN_METHOD,
        idToken: credential.identityToken, // This token from Apple should contain the originalNonce if Apple processed it
        rawNonce: originalNonce, // Pass the original (unhashed) nonce to Firebase
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException on Apple signIn: ${e.code} - ${e.message}');
      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      print('SignInWithAppleAuthorizationException on Apple signIn: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Generic exception on Apple signIn: $e');
      return null;
    }
  }
}
