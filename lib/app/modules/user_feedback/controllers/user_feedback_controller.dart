import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/FeedBackModel.dart';
import 'package:quickalert/quickalert.dart';

class UserFeedbackController extends GetxController {
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  var selectedCategory = "Performance".obs; // Default category
  var selectedRating = 5.obs; // Default rating
  var isSubmitting = false.obs;
  var isLoading = false.obs;
  var userFeedbacks = <FeedBackModel>[].obs;

  List<String> get feedbackCategories => [
    'feedback_performance'.tr,
    'feedback_bug_report'.tr,
    'feedback_feature_request'.tr,
    'feedback_ui_ux'.tr,
    'feedback_product_quality'.tr,
    'feedback_delivery_service'.tr,
    'feedback_customer_support'.tr,
    'feedback_other'.tr,
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUserFeedbacks();
  }

  @override
  void onClose() {
    feedbackController.dispose();
    titleController.dispose();
    super.onClose();
  }

  // Submit feedback to Supabase
  Future<void> submitFeedback() async {
    if (!_validateInput()) return;

    isSubmitting.value = true;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar(
          'feedback_error_title'.tr,
          'please_login_to_submit'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Get user profile data
      final userProfile = await _getUserProfile(user.uid);

      // Prepare feedback data
      final feedbackData = {
        'userid': user.uid,
        'username': userProfile['name'] ?? 'anonymous_user'.tr,
        'userprofileurl': userProfile['profilepic'] ?? '',
        'email': userProfile['email'] ?? user.email ?? '',
        'phone': userProfile['phoneNumber'] ?? '',
        'feedbacktype': _mapCategoryToType(selectedCategory.value),
        'rating': selectedRating.value,
        'title': titleController.text.trim(),
        'message': feedbackController.text.trim(),
        'status': 'pending',
        'adminresponse': '',
        'createdat': DateTime.now().toIso8601String(),
      };

      // Insert feedback into Firestore
      final response = await FirebaseFirestore.instance
          .collection('feedbacks')
          .add(feedbackData);

      // Add to local list
      userFeedbacks.insert(
        0,
        FeedBackModel.fromJson({...feedbackData, 'feedbackid': response.id}),
      );

      // Clear form
      _clearForm();

      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.success,
        title: 'feedback_success_title'.tr,
        text: 'feedback_success_message'.tr,
      );
    } catch (e) {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: 'feedback_error_title'.tr,
        text: 'feedback_error_message'.trParams({'error': e.toString()}),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Fetch user's previous feedbacks
  Future<void> fetchUserFeedbacks() async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('userid', isEqualTo: user.uid)
          .orderBy('createdat', descending: true)
          .limit(10)
          .get();

      userFeedbacks.clear();
      for (var item in response.docs) {
        userFeedbacks.add(FeedBackModel.fromJson(item.data()));
      }
    } catch (e) {
      print('Error fetching user feedbacks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    try {
      final response = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: userId)
          .limit(1)
          .get();

      return response.docs.isNotEmpty ? response.docs.first.data() : {};
    } catch (e) {
      print('Error fetching user profile: $e');
      return {};
    }
  }

  // Validate input fields
  bool _validateInput() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'feedback_error_title'.tr,
        'enter_feedback_title'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'feedback_error_title'.tr,
        'enter_feedback_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (titleController.text.trim().length < 3) {
      Get.snackbar(
        'feedback_error_title'.tr,
        'title_min_length'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (feedbackController.text.trim().length < 6) {
      Get.snackbar(
        'feedback_error_title'.tr,
        'message_min_length'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Map category to feedback type
  String _mapCategoryToType(String category) {
    switch (category.toLowerCase()) {
      case 'performance':
        return 'app';
      case 'bug report':
        return 'app';
      case 'feature request':
        return 'app';
      case 'ui/ux':
        return 'app';
      case 'product quality':
        return 'product';
      case 'delivery service':
        return 'delivery';
      case 'customer support':
        return 'service';
      default:
        return 'general';
    }
  }

  // Clear form fields
  void _clearForm() {
    feedbackController.clear();
    titleController.clear();
    selectedCategory.value = "Performance";
    selectedRating.value = 5;
  }

  // Update selected category
  void updateCategory(String category) {
    selectedCategory.value = category;
  }

  // Update selected rating
  void updateRating(int rating) {
    selectedRating.value = rating;
  }

  // Refresh feedbacks
  Future<void> refreshFeedbacks() async {
    await fetchUserFeedbacks();
  }

  // Delete feedback (if needed)
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(feedbackId)
          .delete();

      userFeedbacks.removeWhere(
        (feedback) => feedback.feedbackId == feedbackId,
      );

      Get.snackbar(
        'feedback_success_title'.tr,
        'feedback_deleted_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'feedback_error_title'.tr,
        'feedback_deleted_error'.trParams({'error': e.toString()}),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get feedback statistics
  Map<String, int> get feedbackStats {
    final stats = {
      'total': userFeedbacks.length,
      'pending': 0,
      'reviewed': 0,
      'resolved': 0,
    };

    for (var feedback in userFeedbacks) {
      switch (feedback.status.toLowerCase()) {
        case 'pending':
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case 'reviewed':
          stats['reviewed'] = (stats['reviewed'] ?? 0) + 1;
          break;
        case 'resolved':
          stats['resolved'] = (stats['resolved'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  // Get average rating
  double get averageRating {
    if (userFeedbacks.isEmpty) return 0.0;

    final totalRating = userFeedbacks.fold<int>(
      0,
      (sum, feedback) => sum + feedback.rating,
    );

    return totalRating / userFeedbacks.length;
  }
}
