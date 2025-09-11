import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/modules/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Observable properties
  final user = Rxn<UserModel>();
  final isLoading = true.obs;
  final isUpdating = false.obs;
  final isUploadingImage = false.obs;

  // Form controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final avatarUrlController = TextEditingController();

  // Form validation
  final formKey = GlobalKey<FormState>();

  // Profile image
  final selectedImageFile = Rxn<File>();
  final uploadProgress = 0.0.obs;
  final purchasedAvatars = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _loadPurchasedAvatars();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    avatarUrlController.dispose();
    super.onClose();
  }

  Future<void> _loadUserProfile() async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        Get.back();
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        user.value = UserModel.fromMap(userDoc.data()!);

        // Populate form controllers
        usernameController.text = user.value!.username;
        emailController.text = user.value!.email;
        avatarUrlController.text = user.value!.avatarUrl;

        print('User profile loaded: ${user.value!.username}');
      } else {
        Get.snackbar('Error', 'User profile not found');
        Get.back();
      }
    } catch (e) {
      print('Error loading user profile: $e');
      Get.snackbar('Error', 'Failed to load profile: $e');
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPurchasedAvatars() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final purchasedAvatarsData = userData['purchasedAvatars'] ?? [];
        purchasedAvatars.value = List<Map<String, String>>.from(
          purchasedAvatarsData.map((item) => Map<String, String>.from(item)),
        );
      }
    } catch (e) {
      print('Error loading purchased avatars: $e');
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImageFile.value = File(pickedFile.path);
        print('Image selected: ${pickedFile.path}');

        // Automatically upload to Firebase Storage
        await _uploadImageToFirebase(selectedImageFile.value!);
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedImageFile.value = File(pickedFile.path);
        print('Image captured: ${pickedFile.path}');

        // Automatically upload to Firebase Storage
        await _uploadImageToFirebase(selectedImageFile.value!);
      }
    } catch (e) {
      print('Error capturing image: $e');
      Get.snackbar('Error', 'Failed to capture image: $e');
    }
  }

  void showImagePickerDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Profile Picture'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose an option to update your profile picture.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Character options section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Character Avatars',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Default character avatars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAvatarOption('assets/cha1.png', isAsset: true),
                        _buildAvatarOption('assets/cha2.png', isAsset: true),
                      ],
                    ),

                    // Purchased avatars section
                    Obx(() {
                      if (purchasedAvatars.isNotEmpty) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Purchased Avatars',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: purchasedAvatars.map((avatar) {
                                return _buildAvatarOption(
                                  avatar['url']!,
                                  isAsset: false,
                                  name: avatar['name'],
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Custom image options
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Gallery'),
                subtitle: const Text('Upload from gallery'),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.purple),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Get.back();
                  pickImageFromCamera();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildAvatarOption(
    String imagePath, {
    required bool isAsset,
    String? name,
  }) {
    return GestureDetector(
      onTap: () {
        Get.back();
        if (isAsset) {
          _selectCharacterAvatar(imagePath);
        } else {
          _selectPurchasedAvatar(imagePath);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.purple, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: isAsset
              ? Image.asset(imagePath, fit: BoxFit.cover, width: 70, height: 70)
              : Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Icon(Icons.person, color: Colors.grey.shade600),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _selectPurchasedAvatar(String downloadUrl) async {
    try {
      // Clear any selected file first
      selectedImageFile.value = null;

      // Set the avatar URL directly since it's already uploaded to Firebase
      avatarUrlController.text = downloadUrl;

      // Trigger UI update for reactive display
      user.value = user.value!.copyWith(avatarUrl: downloadUrl);
    } catch (e) {
      print('Error selecting purchased avatar: $e');
      Get.snackbar('Error', 'Failed to select purchased avatar: $e');
    }
  }

  void _selectCharacterAvatar(String assetPath) async {
    try {
      // Clear any selected file first
      selectedImageFile.value = null;

      // Set the avatar URL to trigger UI update
      avatarUrlController.text = assetPath;

      // Trigger UI update for reactive display
      user.value = user.value!.copyWith(avatarUrl: assetPath);

      // Upload the character image to Firebase Storage
      await _uploadCharacterImageToFirebase(assetPath);
    } catch (e) {
      print('Error selecting character avatar: $e');
      Get.snackbar('Error', 'Failed to select character avatar: $e');
    }
  }

  Future<void> _uploadCharacterImageToFirebase(String assetPath) async {
    try {
      isUploadingImage.value = true;
      uploadProgress.value = 0.0;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Load the asset image as bytes
      final ByteData byteData = await rootBundle.load(assetPath);
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Create unique filename with user ID and timestamp
      final fileName =
          'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create reference to Firebase Storage
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      // Upload bytes with progress tracking
      final uploadTask = storageRef.putData(imageBytes);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        uploadProgress.value = progress;
        print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the avatar URL field automatically
      avatarUrlController.text = downloadUrl;

      // Update the local user object with the new URL
      user.value = user.value!.copyWith(avatarUrl: downloadUrl);
    } catch (e) {
      print('Error uploading character image: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload character image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isUploadingImage.value = false;
      uploadProgress.value = 0.0;
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      isUploadingImage.value = true;
      uploadProgress.value = 0.0;

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Create unique filename with user ID and timestamp
      final fileName =
          'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create reference to Firebase Storage
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      // Upload file with progress tracking
      final uploadTask = storageRef.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        uploadProgress.value = progress;
        print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the avatar URL field automatically
      avatarUrlController.text = downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      Get.snackbar(
        'Upload Failed',
        'Failed to upload image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isUploadingImage.value = false;
      uploadProgress.value = 0.0;
    }
  }

  Future<bool> _checkUsernameAvailability(String username) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Skip check if username hasn't changed
      if (username == user.value?.username) return true;

      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 2) {
      return 'Username must be at least 2 characters';
    }
    if (value.trim().length > 20) {
      return 'Username must be less than 20 characters';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validateAvatarUrl(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!GetUtils.isURL(value.trim())) {
        return 'Please enter a valid URL';
      }
    }
    return null;
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isUpdating.value = true;
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final newUsername = usernameController.text.trim();
      final newAvatarUrl = avatarUrlController.text.trim();

      // Check username availability
      final isUsernameAvailable = await _checkUsernameAvailability(newUsername);
      if (!isUsernameAvailable) {
        Get.snackbar('Error', 'Username is already taken');
        return;
      }

      // Update user document in Firestore (excluding email)
      await _firestore.collection('users').doc(currentUser.uid).update({
        'username': newUsername,
        'avatarUrl': newAvatarUrl,
      });

      // Update local user object
      user.value = user.value!.copyWith(
        username: newUsername,
        avatarUrl: newAvatarUrl,
      );
      var storage = GetStorage();
      storage.write('user', user.value!.toMap());
      await Get.find<ProfileController>().fetchUserProfile();
      Get.back();
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  void removeSelectedImage() {
    selectedImageFile.value = null;
  }

  void resetForm() {
    if (user.value != null) {
      usernameController.text = user.value!.username;
      // Email field is read-only, so we don't reset it
      avatarUrlController.text = user.value!.avatarUrl;
      selectedImageFile.value = null;
    }
  }
}
