import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/auth_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
    // Initialize AuthService
    try {
      await _authService.initialize();
    } catch (e) {
      print('Failed to initialize AuthService: $e');
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
        generalError.value = _authService.lastError ?? 'Google sign-in failed';
      }
    } catch (e) {
      generalError.value = 'Google sign-in error: $e';
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
      emailError.value = 'Please enter your email.';
      isValid = false;
    } else if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError.value = 'Please enter a valid email address.';
      isValid = false;
    }

    // Password validation
    if (passwordController.text.trim().isEmpty) {
      passwordError.value = 'Please enter your password.';
      isValid = false;
    } else if (passwordController.text.trim().length < 6) {
      passwordError.value = 'Password must be at least 6 characters long.';
      isValid = false;
    }

    return isValid;
  }

  Future<void> goGoogleSignIn() async {
    // Clear any previous error messages
    generalError.value = '';

    // Start loading
    signingIn.value = true;

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        try {
          // Check if user exists in Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // User doesn't exist, create new user document
            final newUser = UserModel(
              uid: user.uid,
              username: user.displayName ?? 'Google User',
              email: user.email ?? '',
              phone: user.phoneNumber ?? '',
              role: 'user', // Default role
              profileImg: user.photoURL ?? '',
            );

            // Save user to Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set(newUser.toMap());

            showTopSnackBar(
              Overlay.of(Get.context!),
              CustomSnackBar.success(message: 'Account created successfully'),
            );
          } else {
            Get.snackbar(
              'Welcome Back!',
              'Signed in successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }

          Get.offAllNamed('/home');
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to save user data: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to sign in with Google',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      generalError.value = 'Google sign-in error: $e';
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
