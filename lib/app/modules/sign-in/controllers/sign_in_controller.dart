import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/services/auth_service.dart';

class SignInController extends GetxController {
  // Controllers for TextFields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var signingIn = false.obs;
  // Reactive variables
  var isPasswordHidden = true.obs; // To toggle password visibility
  var isLoading = false.obs; // To show a loading indicator
  var emailError = ''.obs; // Validation error for email
  var passwordError = ''.obs; // Validation error for password
  var generalError = ''.obs; // General error message for login failure
  var mode = Get.arguments ?? 'single'; // Game mode

  // Use shared auth service instead of individual instances
  final AuthService _authService = AuthService.instance;

  // Google Sign-In Method
  Future<void> signInWithGoogle() async {
    try {
      signingIn.value = true;
      clearErrorMessages();

      // Use the shared auth service
      final UserCredential? userCredential = await _authService
          .signInWithGoogle();

      if (userCredential == null) {
        // User canceled the sign-in
        signingIn.value = false;
        return;
      }

      if (userCredential.user != null) {
        await _handleFirebaseUser(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    } catch (e) {
      // Check if it's the specific API error 10 (DEVELOPER_ERROR)
      if (e.toString().contains('ApiException: 10')) {
        print(
          'Detected Google Sign-In configuration error, clearing auth cache...',
        );
        await _clearAuthCacheAndRetry();
      } else {
        generalError.value = '${'google_sign_in_error'.tr}: $e';
        print('Google Sign-In Error: $e');
      }
    } finally {
      signingIn.value = false;
    }
  }

  // Clear auth cache and optionally retry
  Future<void> _clearAuthCacheAndRetry() async {
    try {
      await _authService.clearAuthCache();
      generalError.value = 'auth_cache_cleared'.tr;
      Get.snackbar(
        'info'.tr,
        'auth_cache_cleared_retry'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      generalError.value = '${'google_sign_in_error'.tr}: $e';
      print('Error clearing auth cache: $e');
    }
  }

  // Handle Firebase Auth exceptions
  void _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        generalError.value = 'account_exists_different_credential'.tr;
        break;
      case 'invalid-credential':
        generalError.value = 'invalid_credential'.tr;
        break;
      case 'operation-not-allowed':
        generalError.value = 'google_sign_in_not_enabled'.tr;
        break;
      case 'user-disabled':
        generalError.value = 'user_account_disabled'.tr;
        break;
      case 'user-not-found':
        generalError.value = 'no_user_found'.tr;
        break;
      case 'wrong-password':
        generalError.value = 'wrong_password'.tr;
        break;
      default:
        generalError.value = '${'authentication_error'.tr}: ${e.message}';
    }
  }

  Future<void> _handleFirebaseUser(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          username: user.displayName ?? 'google_user_fallback'.tr,
          email: user.email ?? '',
          role: 'user',
          avatarUrl: user.photoURL ?? '',
          currentGameId: null,
          stats: {'gamesPlayed': 0, 'gamesWon': 0, 'totalPoints': 0},
          fcmToken: fcmToken,
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());
      } else {
        // Update FCM token if changed
        final existingData = userDoc.data() as Map<String, dynamic>;
        if (existingData['fcmToken'] != fcmToken) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'fcmToken': fcmToken});
        }
        Get.snackbar(
          'welcome_back'.tr,
          'signed_in_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      if (mode == 'single') {
        Get.offAllNamed('/single-player');
      } else {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_save_user_data'.trParams({'error': '$e'}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Input validation function
  bool validateInput() {
    bool isValid = true;

    // Email validation
    if (emailController.text.trim().isEmpty) {
      emailError.value = 'please_enter_email'.tr;
      isValid = false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = 'please_enter_valid_email'.tr;
      isValid = false;
    }

    // Password validation
    if (passwordController.text.trim().isEmpty) {
      passwordError.value = 'please_enter_password'.tr;
      isValid = false;
    } else if (passwordController.text.trim().length < 6) {
      passwordError.value = 'password_min_length'.tr;
      isValid = false;
    }

    return isValid;
  }

  // Clear error messages on text change
  void clearErrorMessages() {
    emailError.value = '';
    passwordError.value = '';
    generalError.value = '';
  }
}
