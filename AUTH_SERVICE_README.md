# AuthService - Google Sign In with Firebase Integration

This AuthService class provides a comprehensive integration between Google Sign In and Firebase Authentication using the latest `google_sign_in: ^7.1.1` API patterns.

## Features

- ✅ **Latest API Support**: Built for google_sign_in 7.1.1 with the new authorization-based approach
- ✅ **Firebase Integration**: Seamless integration with Firebase Authentication
- ✅ **Stream-based State Management**: Real-time auth state updates
- ✅ **Comprehensive Error Handling**: User-friendly error messages
- ✅ **Scope Management**: Request additional OAuth scopes dynamically
- ✅ **Server Integration**: Support for server auth codes and authorization headers
- ✅ **Singleton Pattern**: Single instance across your app
- ✅ **Proper Resource Management**: Automatic cleanup and disposal

## Quick Start

### 1. Dependencies

Ensure you have these dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.13.0
  firebase_auth: ^5.7.0
  google_sign_in: ^7.1.1
```

### 2. Platform Setup

Follow the platform-specific setup instructions:

- **Android**: [google_sign_in_android README](https://pub.dev/packages/google_sign_in_android#integration)
- **iOS**: [google_sign_in_ios README](https://pub.dev/packages/google_sign_in_ios#ios-integration)
- **macOS**: [google_sign_in_ios README](https://pub.dev/packages/google_sign_in_ios#macos-integration)
- **Web**: [google_sign_in_web README](https://pub.dev/packages/google_sign_in_web#integration)

### 3. Firebase Setup

Make sure Firebase is properly configured with Firebase Auth and Google Sign In enabled in the Firebase Console.

### 4. Basic Usage

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/data/auth_service.dart';

// Initialize Firebase and AuthService
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

final authService = AuthService();
await authService.initialize();

// Sign in with Google
final user = await authService.signInWithGoogle();
if (user != null) {
  print('Signed in: ${user.email}');
} else {
  print('Sign in failed: ${authService.lastError}');
}

// Sign out
await authService.signOut();
```

## API Reference

### Initialization

```dart
await authService.initialize({
  String? clientId,        // Optional: Platform-specific client ID
  String? serverClientId,  // Optional: Server client ID for backend
});
```

### Authentication

```dart
// Sign in with Google
Future<User?> signInWithGoogle()

// Sign out (keeps account for lightweight auth)
Future<void> signOut()

// Disconnect (removes all permissions)
Future<void> disconnect()
```

### Authorization & Scopes

```dart
// Request additional scopes
Future<GoogleSignInClientAuthorization?> requestScopes(List<String> scopes)

// Get server auth code for backend
Future<String?> getServerAuthCode(List<String> scopes)

// Get authorization headers for API calls
Future<Map<String, String>?> getAuthorizationHeaders(List<String> scopes)
```

### State Monitoring

```dart
// Firebase Auth state changes
Stream<User?> authStateChanges

// Google Sign In state changes  
Stream<GoogleSignInAccount?> googleAuthStateChanges

// Current states
User? currentUser
GoogleSignInAccount? currentGoogleUser
bool isSignedIn
String? lastError
```

## Advanced Usage

### Request Additional Scopes

```dart
const scopes = [
  'https://www.googleapis.com/auth/drive.file',
  'https://www.googleapis.com/auth/contacts.readonly',
];

final authorization = await authService.requestScopes(scopes);
if (authorization != null) {
  // Use authorization.accessToken for API calls
  print('Access token: ${authorization.accessToken}');
}
```

### Make Authorized API Calls

```dart
const scopes = ['https://www.googleapis.com/auth/contacts.readonly'];

final headers = await authService.getAuthorizationHeaders(scopes);
if (headers != null) {
  final response = await http.get(
    Uri.parse('https://people.googleapis.com/v1/people/me/connections'),
    headers: headers,
  );
  // Handle response
}
```

### Server Integration

```dart
const scopes = ['https://www.googleapis.com/auth/drive.file'];

final serverAuthCode = await authService.getServerAuthCode(scopes);
if (serverAuthCode != null) {
  // Send to your backend server
  await sendToBackend(serverAuthCode);
}
```

### Stream-based UI Updates

```dart
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    final user = snapshot.data;
    if (user != null) {
      return SignedInWidget(user: user);
    } else {
      return SignInButton();
    }
  },
)
```

## Error Handling

The AuthService provides comprehensive error handling:

```dart
final user = await authService.signInWithGoogle();
if (user == null) {
  final error = authService.lastError;
  // Handle error appropriately
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Sign In Error'),
      content: Text(error ?? 'Unknown error occurred'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

### Common Error Codes

**GoogleSignInException codes:**
- `canceled` - User canceled the sign in
- `interrupted` - Sign in was interrupted
- `clientConfigurationError` - Configuration error
- `providerConfigurationError` - Provider setup error
- `uiUnavailable` - UI not available
- `userMismatch` - User mismatch error

**FirebaseAuthException codes:**
- `account-exists-with-different-credential` - Account exists with different method
- `invalid-credential` - Invalid or expired credential
- `operation-not-allowed` - Google sign-in not enabled
- `user-disabled` - User account disabled

## Best Practices

### 1. Initialize Early
```dart
// Initialize in main() or app startup
await authService.initialize();
```

### 2. Use Streams for UI Updates
```dart
// Listen to auth state changes instead of polling
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    // Build UI based on auth state
  },
)
```

### 3. Request Scopes When Needed
```dart
// Request scopes only when the feature is accessed
if (needsDriveAccess) {
  await authService.requestScopes(['https://www.googleapis.com/auth/drive.file']);
}
```

### 4. Handle Errors Gracefully
```dart
try {
  await authService.signInWithGoogle();
} on GoogleSignInException catch (e) {
  // Handle Google-specific errors
} on FirebaseAuthException catch (e) {
  // Handle Firebase-specific errors
} catch (e) {
  // Handle unexpected errors
}
```

### 5. Dispose Resources
```dart
@override
void dispose() {
  authService.dispose(); // Clean up streams
  super.dispose();
}
```

## Migration from Pre-7.0 Versions

If you're migrating from older versions of google_sign_in:

1. **Remove old GoogleSignIn initialization** - Use `GoogleSignIn.instance` instead
2. **Update authentication flow** - Use `authenticate()` instead of `signIn()`
3. **Use authorization client** - Get tokens through `authorizationClient` instead of `authentication`
4. **Handle new exception types** - Update error handling for new exception codes

## Complete Example

See `lib/app/widgets/auth_example.dart` for a complete working example that demonstrates all features of the AuthService.

## Troubleshooting

### Common Issues

1. **"Authentication not supported on this platform"**
   - Ensure proper platform configuration
   - Check that OAuth client IDs are correctly set up

2. **"Failed to get Google authorization"**
   - Verify OAuth scopes are valid
   - Check that user has granted necessary permissions

3. **"Firebase Auth error: operation-not-allowed"**
   - Enable Google Sign In in Firebase Console
   - Verify Firebase configuration

4. **iOS/macOS specific issues**
   - Ensure `GoogleService-Info.plist` is properly added
   - Check bundle ID matches Firebase configuration

5. **Android specific issues**
   - Verify `google-services.json` is in the correct location
   - Check SHA-1 fingerprints are added to Firebase

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
import 'dart:developer' as developer;

// Check the console for AuthService logs
// Logs are automatically generated for all operations
```

## License

This code is provided as-is for educational and development purposes.
