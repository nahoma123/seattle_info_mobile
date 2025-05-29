import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider; // Hide to avoid conflict if you were to use it directly
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../domain/auth_repository.dart';

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
    // Apple Sign-In is more complex and requires specific setup for each platform (iOS/macOS/Web)
    // and testing on actual Apple devices or simulators.
    // This is a placeholder implementation.
    print('Attempting Sign in with Apple (placeholder)...');
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // webAuthenticationOptions: WebAuthenticationOptions(  // For web
        //   clientId: 'YOUR_CLIENT_ID_FROM_FIREBASE_OR_APPLE_DEV_CONSOLE',
        //   redirectUri: Uri.parse('YOUR_REDIRECT_URI'),
        // ),
      );

      // Ensure firebase_auth is imported (it should be already)
      // import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
      // Then use fb_auth.AppleAuthProvider or just AppleAuthProvider if no conflict

      final String? rawNonce = credential.nonce; // Capture nonce if available
      
      final OAuthCredential oauthCredential = OAuthCredential(
        providerId: AppleAuthProvider.PROVIDER_ID, // Static constant for 'apple.com'
        signInMethod: AppleAuthProvider.APPLE_SIGN_IN_METHOD, // Static constant for 'apple.com'
        idToken: credential.identityToken,
        rawNonce: rawNonce, // Pass the nonce obtained from Apple
        accessToken: credential.authorizationCode, 
      );
       
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException on Apple signIn: ${e.message}');
      return null;
    } catch (e) {
      print('Generic/Apple exception on Apple signIn: $e');
      // e.g. SignInWithAppleAuthorizationException
      return null;
    }
  }
}
