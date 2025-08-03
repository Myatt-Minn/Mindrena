import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import '../data/auth_service.dart';

/// Example widget demonstrating how to use the AuthService
///
/// This shows the complete integration pattern for Google Sign In with Firebase
class AuthExample extends StatefulWidget {
  const AuthExample({super.key});

  @override
  State<AuthExample> createState() => _AuthExampleState();
}

class _AuthExampleState extends State<AuthExample> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  /// Initialize Firebase and AuthService
  Future<void> _initializeServices() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize AuthService
      await _authService.initialize(
        // Optional: Add your client IDs here
        // clientId: 'your-client-id',
        // serverClientId: 'your-server-client-id',
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Initialization failed: $e';
      });
    }
  }

  /// Handle Google Sign In
  Future<void> _handleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        // Sign in successful
        print('Signed in: ${user.email}');
      } else {
        // Check for error
        final error = _authService.lastError;
        setState(() {
          _errorMessage = error ?? 'Sign in failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle Sign Out
  Future<void> _handleSignOut() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _authService.signOut();
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign out error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle Disconnect (removes all permissions)
  Future<void> _handleDisconnect() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _authService.disconnect();
    } catch (e) {
      setState(() {
        _errorMessage = 'Disconnect error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Request additional scopes (example: Google Drive access)
  Future<void> _requestAdditionalScopes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      const additionalScopes = [
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/contacts.readonly',
      ];

      final authorization = await _authService.requestScopes(additionalScopes);

      if (authorization != null) {
        print('Additional scopes granted');

        // Example: Get authorization headers for API calls
        final headers = await _authService.getAuthorizationHeaders(
          additionalScopes,
        );
        if (headers != null) {
          print('Got authorization headers: $headers');
        }
      } else {
        final error = _authService.lastError;
        setState(() {
          _errorMessage = error ?? 'Failed to get additional scopes';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Scope request error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign In Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            // User info display
            StreamBuilder(
              stream: _authService.authStateChanges,
              builder: (context, snapshot) {
                final user = snapshot.data;

                if (user != null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signed in as:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${user.email}'),
                          Text('Name: ${user.displayName ?? 'N/A'}'),
                          Text('UID: ${user.uid}'),
                        ],
                      ),
                    ),
                  );
                }

                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Not signed in'),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Google user info display
            StreamBuilder(
              stream: _authService.googleAuthStateChanges,
              builder: (context, snapshot) {
                final googleUser = snapshot.data;

                if (googleUser != null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Account:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${googleUser.email}'),
                          Text('Name: ${googleUser.displayName ?? 'N/A'}'),
                          Text('ID: ${googleUser.id}'),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            const Spacer(),

            // Action buttons
            StreamBuilder(
              stream: _authService.authStateChanges,
              builder: (context, snapshot) {
                final isSignedIn = snapshot.data != null;

                if (isSignedIn) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _requestAdditionalScopes,
                        child: const Text('Request Additional Scopes'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignOut,
                        child: const Text('Sign Out'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleDisconnect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Disconnect'),
                      ),
                    ],
                  );
                } else {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    child: const Text('Sign In with Google'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
