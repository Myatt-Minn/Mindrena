import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

class CheckoutController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Data from previous screens
  var selectedPackage = Rxn<dynamic>();
  var paymentMethod = Rxn<dynamic>();

  // Transaction screenshot
  var transactionImage = Rxn<File>();
  var isUploading = false.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedPackage.value = args['package'];
      paymentMethod.value = args['paymentMethod'];
    }
  }

  Future<void> pickTransactionImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        transactionImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> takeTransactionPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        transactionImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to take photo: $e');
    }
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      takeTransactionPhoto();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      pickTransactionImage();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadTransactionImage() async {
    if (transactionImage.value == null) return null;

    try {
      isUploading.value = true;

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName =
          'transaction_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('transactions').child(fileName);

      final uploadTask = storageRef.putFile(transactionImage.value!);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> submitPurchase() async {
    if (transactionImage.value == null) {
      Get.snackbar('Error', 'Please upload transaction screenshot');
      return;
    }

    try {
      isSubmitting.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Upload transaction image
      final imageUrl = await _uploadTransactionImage();
      if (imageUrl == null) {
        Get.snackbar('Error', 'Failed to upload transaction image');
        return;
      }

      // Create purchase record
      final purchaseData = {
        'userId': user.uid,
        'userEmail': user.email,
        'packageId': selectedPackage.value?.id,
        'coins': selectedPackage.value?.coins,
        'price': selectedPackage.value?.price,
        'paymentMethod': paymentMethod.value?.id,
        'paymentMethodName': paymentMethod.value?.name,
        'transactionImageUrl': imageUrl,
        'status': 'pending', // pending, approved, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('purchases').add(purchaseData);

      // Show success dialog
      await QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.success,
        title: 'Purchase Submitted!',
        text:
            'Your purchase has been submitted successfully. Please wait a few hours for admin confirmation. You will receive the coins once approved.',
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () {
          Get.back(); // Close dialog
          Get.back(); // Close checkout screen
          Get.back(); // Close checkout screen
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit purchase: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
