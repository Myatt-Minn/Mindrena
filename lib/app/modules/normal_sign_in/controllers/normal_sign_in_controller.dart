import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/auth_service.dart';

class NormalSignInController extends GetxController {
  // Controllers for TextFields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive variables
  var isPasswordHidden = true.obs; // To toggle password visibility
  var isLoading = false.obs; // To show a loading indicator
  var emailError = ''.obs; // Validation error for email
  var passwordError = ''.obs; // Validation error for password
  var generalError = ''.obs; // General error message for login failure

  // AuthService instance
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _initializeAuthService();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _initializeAuthService() async {
    try {
      await _authService.initialize();
    } catch (e) {
      print('Failed to initialize AuthService: $e');
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Input validation function
  bool validateInput() {
    bool isValid = true;

    // Clear previous errors
    emailError.value = '';
    passwordError.value = '';

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

  // Email/Password Sign-In or Sign-Up function
  Future<void> signInWithEmailPassword() async {
    // Clear any previous error messages
    generalError.value = '';

    // Validate input first
    if (!validateInput()) {
      return;
    }

    // Start loading
    isLoading.value = true;

    try {
      // First, try to sign in
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        await _handleFirebaseUser(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // User doesn't exist, try to create a new account
        try {
          UserCredential newUserCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );

          if (newUserCredential.user != null) {
            // Show success message for new user
            Get.snackbar(
              'Welcome!',
              'Account created successfully. Welcome to Mindrena!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            await _handleFirebaseUser(newUserCredential.user!);
          }
        } on FirebaseAuthException catch (signUpError) {
          switch (signUpError.code) {
            case 'email-already-in-use':
              // This means the user exists but password was wrong
              generalError.value =
                  'Account exists but password is incorrect. Please check your password.';
              break;
            case 'weak-password':
              generalError.value =
                  'Password is too weak. Please use at least 6 characters.';
              break;
            case 'invalid-email':
              generalError.value = 'The email address is not valid.';
              break;
            default:
              print('Sign Up Error Code: ${signUpError.code}');
              print('Sign Up Error Message: ${signUpError.message}');
              generalError.value =
                  'Failed to create account: ${signUpError.message ?? "Unknown error"}';
          }
        } catch (signUpError) {
          generalError.value = 'Failed to create account: $signUpError';
        }
      } else {
        // Handle other sign-in errors
        switch (e.code) {
          case 'wrong-password':
            generalError.value = 'Wrong password provided for that user.';
            break;
          case 'invalid-email':
            generalError.value = 'The email address is not valid.';
            break;
          case 'user-disabled':
            generalError.value = 'This user account has been disabled.';
            break;
          case 'too-many-requests':
            generalError.value =
                'Too many failed attempts. Please try again later.';
            break;
          case 'channel-error':
            generalError.value =
                'Please check your internet connection and try again.';
            break;
          case 'network-request-failed':
            generalError.value = 'Network error. Please check your connection.';
            break;
          default:
            print('Firebase Auth Error Code: ${e.code}');
            print('Firebase Auth Error Message: ${e.message}');
            generalError.value =
                'Sign in failed: ${e.message ?? "Unknown error"}';
        }
      }
    } catch (e) {
      generalError.value = 'sign_in_error'.trParams({'error': '$e'});
    } finally {
      // Stop loading
      isLoading.value = false;
    }
  }

  // Handle Firebase user after successful sign-in
  Future<void> _handleFirebaseUser(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = UserModel(
          uid: user.uid,
          username: user.displayName ?? 'User',
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

  // Clear error messages on text change
  void clearErrorMessages() {
    emailError.value = '';
    passwordError.value = '';
    generalError.value = '';
  }

  // Navigate to sign up page
  void goToSignUp() {
    Get.toNamed('/sign-up'); // Assuming you have a sign-up route
  }

  // Navigate back to Google sign-in
  void goToGoogleSignIn() {
    Get.back();
  }
}
