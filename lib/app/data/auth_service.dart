import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Google Sign In instance (using singleton)
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Stream controllers for authentication state
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();
  final StreamController<GoogleSignInAccount?> _googleAuthController =
      StreamController<GoogleSignInAccount?>.broadcast();

  // Current user states
  GoogleSignInAccount? _currentGoogleUser;
  User? _currentFirebaseUser;
  bool _isInitialized = false;

  // Error handling
  String? _lastError;

  /// Stream of Firebase Auth state changes
  Stream<User?> get authStateChanges => _authStateController.stream;

  /// Stream of Google Sign In state changes
  Stream<GoogleSignInAccount?> get googleAuthStateChanges =>
      _googleAuthController.stream;

  /// Current Firebase user
  User? get currentUser => _currentFirebaseUser;

  /// Current Google user
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Last error message
  String? get lastError => _lastError;

  /// Whether user is signed in
  bool get isSignedIn => _currentFirebaseUser != null;

  /// Whether user is signed in to Google but not Firebase
  bool get isGoogleOnlySignedIn =>
      _currentGoogleUser != null && _currentFirebaseUser == null;

  /// Initialize the AuthService
  ///
  /// [clientId] - Optional client ID for Google Sign In (platform-specific)
  /// [serverClientId] - Optional server client ID for backend integration
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_isInitialized) return;

    try {
      // Initialize Google Sign In with client IDs if provided
      await _googleSignIn.initialize(
        clientId: clientId,
        serverClientId: serverClientId,
      );

      // Set current Firebase user from existing auth state
      _currentFirebaseUser = _firebaseAuth.currentUser;

      // Listen to Firebase Auth state changes
      _firebaseAuth.authStateChanges().listen(_handleFirebaseAuthStateChange);

      // Listen to Google Sign In authentication events
      _googleSignIn.authenticationEvents
          .listen(_handleGoogleAuthenticationEvent)
          .onError(_handleGoogleAuthenticationError);

      // Attempt lightweight authentication to restore Google Sign In state
      _currentGoogleUser = await _googleSignIn
          .attemptLightweightAuthentication();

      // If lightweight authentication found a Google user but no Firebase user,
      // try to authenticate with Firebase using the existing Google session
      if (_currentGoogleUser != null && _currentFirebaseUser == null) {
        try {
          final GoogleSignInAuthentication googleAuth =
              _currentGoogleUser!.authentication;

          if (googleAuth.idToken != null) {
            final credential = GoogleAuthProvider.credential(
              idToken: googleAuth.idToken,
            );

            await _firebaseAuth.signInWithCredential(credential);

            developer.log(
              'Successfully restored Firebase authentication from existing Google session',
              name: 'AuthService',
            );
          }
        } catch (e) {
          developer.log(
            'Failed to restore Firebase authentication: $e',
            name: 'AuthService',
          );
          // Don't throw here, just log the error and continue
        }
      }

      _isInitialized = true;
      _clearError();

      developer.log(
        'AuthService initialized successfully. Firebase user: ${_currentFirebaseUser?.email}, Google user: ${_currentGoogleUser?.email}',
        name: 'AuthService',
      );
    } catch (e) {
      _setError('Failed to initialize AuthService: $e');
      developer.log(
        'AuthService initialization failed: $e',
        name: 'AuthService',
      );
      rethrow;
    }
  }

  /// Sign in with Google
  ///
  /// Returns the Firebase User if successful, null otherwise
  Future<User?> signInWithGoogle() async {
    _ensureInitialized();

    try {
      _clearError();

      developer.log('Starting Google Sign In process', name: 'AuthService');

      // For Firebase authentication, we only need the ID token
      // The access token is optional and mainly for API calls
      GoogleSignInAccount googleUser;

      if (_googleSignIn.supportsAuthenticate()) {
        // Use authenticate method - this should only prompt once
        googleUser = await _googleSignIn.authenticate();
        developer.log('Google authentication successful', name: 'AuthService');
      } else {
        _setError('auth_error_google_ui_unavailable');
        return null;
      }

      // Get the authentication tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        _setError('auth_error_google_no_token');
        return null;
      }

      developer.log('Got Google authentication tokens', name: 'AuthService');

      // Create Firebase credential with just the ID token
      // For basic Firebase auth, we don't need the access token
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      developer.log(
        'Google Sign In successful for user: ${userCredential.user?.email}',
        name: 'AuthService',
      );

      return userCredential.user;
    } on GoogleSignInException catch (e) {
      final errorMessage = _getGoogleSignInErrorMessage(e);
      _setError(errorMessage);
      developer.log('Google Sign In error: $errorMessage', name: 'AuthService');
      return null;
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getFirebaseAuthErrorMessage(e);
      _setError(errorMessage);
      developer.log('Firebase Auth error: $errorMessage', name: 'AuthService');
      return null;
    } catch (e) {
      final errorMessage = 'auth_error_unexpected_signin'.trParams({
        'error': e.toString(),
      });
      _setError(errorMessage);
      developer.log('Unexpected sign in error: $e', name: 'AuthService');
      return null;
    }
  }

  /// Sign out from both Google and Firebase
  Future<void> signOut() async {
    _ensureInitialized();

    try {
      _clearError();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google (but keep the account for future lightweight auth)
      await _googleSignIn.signOut();

      developer.log('Sign out successful', name: 'AuthService');
    } catch (e) {
      final errorMessage = 'auth_error_signout'.trParams({
        'error': e.toString(),
      });
      _setError(errorMessage);
      developer.log('Sign out error: $e', name: 'AuthService');
      rethrow;
    }
  }

  /// Disconnect Google account completely (removes all permissions)
  Future<void> disconnect() async {
    _ensureInitialized();

    try {
      _clearError();

      // Sign out from Firebase first
      await _firebaseAuth.signOut();

      // Disconnect Google account (removes all permissions)
      await _googleSignIn.disconnect();

      developer.log('Disconnect successful', name: 'AuthService');
    } catch (e) {
      final errorMessage = 'auth_error_disconnect'.trParams({
        'error': e.toString(),
      });
      _setError(errorMessage);
      developer.log('Disconnect error: $e', name: 'AuthService');
      rethrow;
    }
  }

  /// Request additional scopes for the current Google user
  ///
  /// [scopes] - List of additional scopes to request
  /// Returns the authorization object if successful
  Future<GoogleSignInClientAuthorization?> requestScopes(
    List<String> scopes,
  ) async {
    _ensureInitialized();

    if (_currentGoogleUser == null) {
      _setError('auth_error_no_google_user');
      return null;
    }

    try {
      _clearError();

      final authorization = await _currentGoogleUser!.authorizationClient
          .authorizeScopes(scopes);

      developer.log(
        'Additional scopes authorized: $scopes',
        name: 'AuthService',
      );
      return authorization;
    } on GoogleSignInException catch (e) {
      final errorMessage = _getGoogleSignInErrorMessage(e);
      _setError(errorMessage);
      developer.log(
        'Scope authorization error: $errorMessage',
        name: 'AuthService',
      );
      return null;
    } catch (e) {
      final errorMessage = 'auth_error_scope_request'.trParams({
        'error': e.toString(),
      });
      _setError(errorMessage);
      developer.log('Scope request error: $e', name: 'AuthService');
      return null;
    }
  }

  /// Get server auth code for backend integration
  ///
  /// [scopes] - List of scopes to include in the server auth code
  /// Returns the server auth code if successful
  Future<String?> getServerAuthCode(List<String> scopes) async {
    _ensureInitialized();

    if (_currentGoogleUser == null) {
      _setError('auth_error_no_google_user');
      return null;
    }

    try {
      _clearError();

      final serverAuth = await _currentGoogleUser!.authorizationClient
          .authorizeServer(scopes);

      if (serverAuth == null) {
        _setError('auth_error_server_auth_code');
        return null;
      }

      developer.log('Server auth code generated', name: 'AuthService');
      return serverAuth.serverAuthCode;
    } on GoogleSignInException catch (e) {
      final errorMessage = _getGoogleSignInErrorMessage(e);
      _setError(errorMessage);
      developer.log(
        'Server auth code error: $errorMessage',
        name: 'AuthService',
      );
      return null;
    } catch (e) {
      final errorMessage = 'auth_error_server_auth_code'.trParams({
        'error': e.toString(),
      });
      _setError(errorMessage);
      developer.log('Server auth code error: $e', name: 'AuthService');
      return null;
    }
  }

  /// Get authorization headers for making API calls
  ///
  /// [scopes] - List of scopes needed for the API call
  /// Returns headers map if successful
  ///
  /// Note: This may prompt the user for additional permissions if needed
  Future<Map<String, String>?> getAuthorizationHeaders(
    List<String> scopes,
  ) async {
    _ensureInitialized();

    if (_currentGoogleUser == null) {
      _setError('auth_error_no_google_user');
      return null;
    }

    try {
      _clearError();

      // First try to get existing authorization without prompting
      var authorization = await _currentGoogleUser!.authorizationClient
          .authorizationForScopes(scopes);

      // If no existing authorization, request new authorization
      authorization ??= await _currentGoogleUser!.authorizationClient
          .authorizeScopes(scopes);

      // Get headers using the authorization
      final headers = await _currentGoogleUser!.authorizationClient
          .authorizationHeaders(scopes);

      if (headers == null) {
        _setError('auth_error_auth_headers');
        return null;
      }

      developer.log(
        'Authorization headers generated for scopes: $scopes',
        name: 'AuthService',
      );
      return headers;
    } on GoogleSignInException catch (e) {
      final errorMessage = _getGoogleSignInErrorMessage(e);
      _setError(errorMessage);
      developer.log(
        'Authorization headers error: $errorMessage',
        name: 'AuthService',
      );
      return null;
    } catch (e) {
      final errorMessage = 'auth_error_auth_headers'.trParams({
        'error': e.toString(),
      });
      _setError(errorMessage);
      developer.log('Authorization headers error: $e', name: 'AuthService');
      return null;
    }
  }

  /// Handle Firebase Auth state changes
  void _handleFirebaseAuthStateChange(User? user) {
    _currentFirebaseUser = user;
    _authStateController.add(user);

    if (user != null) {
      developer.log(
        'Firebase user signed in: ${user.email}',
        name: 'AuthService',
      );
    } else {
      developer.log('Firebase user signed out', name: 'AuthService');
    }
  }

  /// Handle Google authentication events
  Future<void> _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    _currentGoogleUser = user;
    _googleAuthController.add(user);

    if (user != null) {
      developer.log(
        'Google user signed in: ${user.email}',
        name: 'AuthService',
      );
    } else {
      developer.log('Google user signed out', name: 'AuthService');
    }
  }

  /// Handle Google authentication errors
  Future<void> _handleGoogleAuthenticationError(Object error) async {
    final errorMessage = error is GoogleSignInException
        ? _getGoogleSignInErrorMessage(error)
        : 'Unknown Google authentication error: $error';

    _setError(errorMessage);
    developer.log(
      'Google authentication error: $errorMessage',
      name: 'AuthService',
    );

    // Clear the current user on error
    _currentGoogleUser = null;
    _googleAuthController.add(null);
  }

  /// Get user-friendly error message for GoogleSignInException
  String _getGoogleSignInErrorMessage(GoogleSignInException e) {
    return switch (e.code) {
      // These will be translation keys
      GoogleSignInExceptionCode.canceled => 'auth_error_google_canceled',
      GoogleSignInExceptionCode.interrupted => 'auth_error_google_interrupted',
      GoogleSignInExceptionCode.clientConfigurationError =>
        'auth_error_google_client_config',
      GoogleSignInExceptionCode.providerConfigurationError =>
        'auth_error_google_provider_config',
      GoogleSignInExceptionCode.uiUnavailable =>
        'auth_error_google_ui_unavailable',
      GoogleSignInExceptionCode.userMismatch =>
        'auth_error_google_user_mismatch',
      GoogleSignInExceptionCode.unknownError => 'auth_error_google_unknown',
    };
  }

  /// Get user-friendly error message for FirebaseAuthException
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    return switch (e.code) {
      // These will be translation keys
      'account-exists-with-different-credential' =>
        'auth_error_firebase_diff_credential',
      'invalid-credential' => 'auth_error_firebase_invalid_credential',
      'operation-not-allowed' => 'auth_error_firebase_op_not_allowed',
      'user-disabled' => 'auth_error_firebase_user_disabled',
      'user-not-found' => 'auth_error_firebase_user_not_found',
      'wrong-password' => 'auth_error_firebase_wrong_password',
      'invalid-verification-code' => 'auth_error_firebase_invalid_code',
      'invalid-verification-id' => 'auth_error_firebase_invalid_id',
      _ => 'auth_error_firebase_generic'.trParams({
        'code': e.code,
        'message': e.message ?? '',
      }),
    };
  }

  /// Set error message
  void _setError(String error) {
    _lastError = error;
  }

  /// Clear error message
  void _clearError() {
    _lastError = null;
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'AuthService must be initialized before use. Call initialize() first.',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
    _googleAuthController.close();
    _isInitialized = false;
  }
}
