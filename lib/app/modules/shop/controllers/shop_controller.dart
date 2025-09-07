import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';

class ShopController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Observable variables
  var userPoints = 0.obs;
  var userCoins = 0.obs;
  var isLoading = true.obs;
  var selectedTab = 0.obs;
  var purchasedItems = <String>[].obs;
  var purchasedAvatars =
      <Map<String, String>>[].obs; // Store avatar info: {id, name, url}
  var purchasedStickers =
      <Map<String, String>>[].obs; // Store sticker info: {id, name, url}
  var currentUserAvatar = ''.obs;

  // Shop items
  var avatarItems = <ShopItem>[].obs;
  var stickerItems = <ShopItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeShopItems();
  }

  /// Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userPoints.value = userData['stats']['totalPoints'] ?? 0;
        userCoins.value =
            userData['stats']['coins'] ?? 0; // Get coins directly from stats
        currentUserAvatar.value = userData['avatarUrl'] ?? '';
        purchasedItems.value = List<String>.from(
          userData['purchasedItems'] ?? [],
        );
        purchasedAvatars.value = List<Map<String, String>>.from(
          (userData['purchasedAvatars'] ?? []).map(
            (item) => Map<String, String>.from(item),
          ),
        );
        purchasedStickers.value = List<Map<String, String>>.from(
          (userData['purchasedStickers'] ?? []).map(
            (item) => Map<String, String>.from(item),
          ),
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize shop items
  void _initializeShopItems() {
    // Avatar items
    avatarItems.value = [
      ShopItem(
        id: 'avatar_1',
        name: 'Ethan Cross',
        description: 'Scared Green Guy',
        price: 500,
        imageUrl: 'assets/cha3.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_2',
        name: 'Chloe Hart',
        description: 'Wondering Purple Girl',
        price: 750,
        imageUrl: 'assets/cha4.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_3',
        name: 'Sophia Brooks',
        description: 'Shy Pink Girl',
        price: 600,
        imageUrl: 'assets/cha5.jpeg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_4',
        name: 'Lucas Reed',
        description: 'Nice Red Guy',
        price: 800,
        imageUrl: 'assets/cha6.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_5',
        name: 'Emily Rivers',
        description: 'Cute Girl',
        price: 900,
        imageUrl: 'assets/cha7.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_5',
        name: 'Isabella Lane',
        description: 'Ambitious Gray Girl',
        price: 900,
        imageUrl: 'assets/cha8.jpeg',
        type: ShopItemType.avatar,
      ),
    ];

    // Sticker items
    stickerItems.value = [
      ShopItem(
        id: 'sticker_1',
        name: 'Victory Sticker',
        description: 'Show your victory!',
        price: 100,
        imageUrl: 'assets/happy.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_2',
        name: 'Fire Sticker',
        description: 'You\'re on fire!',
        price: 150,
        imageUrl: 'assets/confused.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_3',
        name: 'Crown Sticker',
        description: 'You\'re the king!',
        price: 200,
        imageUrl: 'assets/shocked.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_4',
        name: 'Star Sticker',
        description: 'You\'re a star!',
        price: 120,
        imageUrl: 'assets/angry.png',
        type: ShopItemType.sticker,
      ),
    ];
  }

  /// Switch between tabs
  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// Check if item is purchased
  bool isItemPurchased(String itemId) {
    return purchasedItems.contains(itemId);
  }

  /// Check if user can afford item (checking against coins, not raw points)
  bool canAffordItem(int price) {
    return userCoins.value >= price;
  }

  /// Purchase an item
  Future<void> purchaseItem(ShopItem item) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showErrorMessage('Please log in to make purchases');
        return;
      }

      if (isItemPurchased(item.id)) {
        _showErrorMessage('You already own this item');
        return;
      }

      if (!canAffordItem(item.price)) {
        _showErrorMessage('Not enough coins to purchase this item');
        return;
      }

      // Show confirmation dialog
      final confirmed = await _showPurchaseConfirmation(item);
      if (!confirmed) return;

      // Deduct coins directly (no more point conversion)
      final newCoins = userCoins.value - item.price;
      final newPurchasedItems = [...purchasedItems, item.id];

      Map<String, dynamic> updateData = {
        'stats.coins': newCoins, // Update coins directly
        'purchasedItems': newPurchasedItems,
      };

      // If purchasing an avatar, upload it to Firebase Storage first
      if (item.type == ShopItemType.avatar) {
        final uploadedUrl = await _uploadAvatarToFirebase(
          item.imageUrl,
          user.uid,
        );
        if (uploadedUrl != null) {
          updateData['avatarUrl'] = uploadedUrl;
          currentUserAvatar.value = uploadedUrl;

          // Add to purchased avatars list
          final avatarInfo = {
            'id': item.id,
            'name': item.name,
            'url': uploadedUrl,
          };
          final newPurchasedAvatars = [...purchasedAvatars, avatarInfo];
          updateData['purchasedAvatars'] = newPurchasedAvatars;
          purchasedAvatars.add(avatarInfo);
        } else {
          _showErrorMessage('Failed to upload avatar. Please try again.');
          return;
        }
      }

      // If purchasing a sticker, add it to purchased stickers list
      if (item.type == ShopItemType.sticker) {
        final stickerInfo = {
          'id': item.id,
          'name': item.name,
          'url': item.imageUrl,
        };
        final newPurchasedStickers = [...purchasedStickers, stickerInfo];
        updateData['purchasedStickers'] = newPurchasedStickers;
        purchasedStickers.add(stickerInfo);
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Update local state
      userCoins.value = newCoins; // Update coins directly
      purchasedItems.add(item.id);

      _showSuccessMessage('${item.name} purchased successfully!');
    } catch (e) {
      print('Error purchasing item: $e');
      _showErrorMessage('Failed to purchase item. Please try again.');
    }
  }

  /// Show purchase confirmation dialog
  Future<bool> _showPurchaseConfirmation(ShopItem item) async {
    bool? result = await QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.confirm,
      title: 'Confirm Purchase',
      text: 'Purchase ${item.name} for ${item.price} coins?',
      confirmBtnText: 'Purchase',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.purple,
      onConfirmBtnTap: () {
        Get.back(result: true);
      },
    );
    return result ?? false; // Return false if result is null
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.success,
      title: 'Success!',
      text: message,
      confirmBtnColor: Colors.green,
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.error,
      title: 'Error',
      text: message,
      confirmBtnColor: Colors.red,
    );
  }

  /// Refresh user data
  Future<void> refreshData() async {
    await _loadUserData();
  }

  /// Get purchased avatars for use in other controllers
  List<Map<String, String>> getPurchasedAvatars() {
    return purchasedAvatars.toList();
  }

  /// Get purchased stickers for use in other controllers
  List<Map<String, String>> getPurchasedStickers() {
    return purchasedStickers.toList();
  }

  /// Upload avatar asset to Firebase Storage
  Future<String?> _uploadAvatarToFirebase(
    String assetPath,
    String userId,
  ) async {
    try {
      // Load the asset image as bytes
      final ByteData byteData = await rootBundle.load(assetPath);
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Create unique filename with user ID and timestamp
      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create reference to Firebase Storage
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      // Upload bytes
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar to Firebase: $e');
      return null;
    }
  }
}

/// Shop item model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final ShopItemType type;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
  });
}

/// Shop item types
enum ShopItemType { avatar, sticker }
