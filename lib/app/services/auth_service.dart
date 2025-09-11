import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Single GoogleSignIn instance with platform-specific configuration
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Only specify clientId for iOS, Android should use automatic configuration
    clientId: Platform.isIOS
        ? '401918120039-kff7a97lbja1ddljuod3u31i0nif78e2.apps.googleusercontent.com'
        : null,
  );

  // Getters
  FirebaseAuth get firebaseAuth => _firebaseAuth;
  GoogleSignIn get googleSignIn => _googleSignIn;
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Listen to auth state changes if needed
    _firebaseAuth.authStateChanges().listen((User? user) {
      // Handle auth state changes globally if needed
    });
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process...');
      print(
        'Platform: ${Platform.isAndroid
            ? "Android"
            : Platform.isIOS
            ? "iOS"
            : "Other"}',
      );
      print(
        'GoogleSignIn clientId: ${_googleSignIn.clientId ?? "auto-configured"}',
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('User canceled the sign-in');
        return null;
      }

      print('Google user signed in: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Got Google authentication tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Created Firebase credential, signing in to Firebase...');

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      print('Firebase sign-in successful: ${userCredential.user?.email}');

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }

  /// Disconnect Google account completely (removes all permissions)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
    } catch (e) {
      print("Error disconnecting: $e");
      rethrow;
    }
  }

  /// Clear authentication cache and reset sign-in state
  /// Use this when experiencing sign-in errors
  Future<void> clearAuthCache() async {
    try {
      // First sign out from both services
      await signOut();
      // Then disconnect completely to clear cache
      await disconnect();
      print("Authentication cache cleared successfully");
    } catch (e) {
      print("Error clearing auth cache: $e");
    }
  }
}
