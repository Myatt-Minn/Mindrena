import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/auth_service.dart';

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

  // AuthService instance (single instance)
  final AuthService _authService = AuthService();

  @override
  void onInit() async {
    super.onInit();
    try {
      await _authService.initialize();
      // Check if already signed in
      final user = _authService.currentUser;
      if (user != null) {
        await _handleFirebaseUser(user); // See below
      }
    } catch (e) {
      print('Failed to initialize AuthService: $e');
    }
  }

  Future<void> _handleFirebaseUser(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          username: user.displayName ?? 'google_user_fallback'.tr,
          email: user.email ?? '',
          role: 'user',
          avatarUrl: user.photoURL ?? '',
          currentGameId: null,
          stats: {'gamesPlayed': 0, 'gamesWon': 0, 'totalPoints': 0},
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());
      } else {
        Get.snackbar(
          'welcome_back'.tr,
          'signed_in_successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      Get.offAllNamed('/home');
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

  // Google Sign-In function
  Future<void> signInWithGoogle() async {
    // Clear any previous error messages
    generalError.value = '';

    // Start loading
    signingIn.value = true;

    try {
      final User? user = await _authService.signInWithGoogle();

      if (user != null) {
        // Successfully signed in
        Get.offAllNamed('/home');
      } else {
        // Sign in failed but no exception was thrown
        generalError.value =
            (_authService.lastError ?? 'google_sign_in_failed').tr;
      }
    } catch (e) {
      generalError.value = 'google_sign_in_error'.trParams({'error': '$e'});
    } finally {
      // Stop loading
      signingIn.value = false;
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

  Future<void> goGoogleSignIn() async {
    generalError.value = '';
    signingIn.value = true;
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _handleFirebaseUser(user);
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_to_sign_in_google'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      generalError.value = 'google_sign_in_error'.trParams({'error': '$e'});
    } finally {
      signingIn.value = false;
    }
  }

  // Clear error messages on text change
  void clearErrorMessages() {
    emailError.value = '';
    passwordError.value = '';
    generalError.value = '';
  }
}
