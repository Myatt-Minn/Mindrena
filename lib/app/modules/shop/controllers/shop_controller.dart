import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/quickalert.dart';

class ShopController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables
  var userPoints = 0.obs;
  var userCoins = 0.obs;
  var isLoading = true.obs;
  var selectedTab = 0.obs;
  var purchasedItems = <String>[].obs;
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
        userCoins.value = _calculateCoins(userPoints.value);
        currentUserAvatar.value = userData['avatarUrl'] ?? '';
        purchasedItems.value = List<String>.from(
          userData['purchasedItems'] ?? [],
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
        name: 'Warrior Avatar',
        description: 'Brave warrior character',
        price: 500,
        imageUrl: 'assets/cha3.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_2',
        name: 'Wizard Avatar',
        description: 'Magical wizard character',
        price: 750,
        imageUrl: 'assets/cha4.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_3',
        name: 'Ninja Avatar',
        description: 'Stealthy ninja character',
        price: 600,
        imageUrl: 'assets/cha5.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_4',
        name: 'Princess Avatar',
        description: 'Royal princess character',
        price: 800,
        imageUrl: 'assets/cha6.jpg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_4',
        name: 'Princess Avatar',
        description: 'Royal princess character',
        price: 800,
        imageUrl: 'assets/cha7.jpg',
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

  /// Check if user can afford item
  bool canAffordItem(int price) {
    return userPoints.value >= price;
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
        _showErrorMessage('Not enough points to purchase this item');
        return;
      }

      // Show confirmation dialog
      final confirmed = await _showPurchaseConfirmation(item);
      if (!confirmed) return;

      // Update user data in Firestore
      final newPoints = userPoints.value - item.price;
      final newPurchasedItems = [...purchasedItems, item.id];

      Map<String, dynamic> updateData = {
        'stats.totalPoints': newPoints, // Update the totalPoints in stats
        'purchasedItems': newPurchasedItems,
      };

      // If purchasing an avatar, set it as current avatar
      if (item.type == ShopItemType.avatar) {
        updateData['avatarUrl'] = item.imageUrl;
        currentUserAvatar.value = item.imageUrl;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Update local state
      userPoints.value = newPoints;
      userCoins.value = _calculateCoins(newPoints);
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
      text: 'Purchase ${item.name} for ${item.price} points?',
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

  /// Calculate coins based on points (50 coins per 100 points)
  int _calculateCoins(int points) {
    return (points / 100).floor() * 50;
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
