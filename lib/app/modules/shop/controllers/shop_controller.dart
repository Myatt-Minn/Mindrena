import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/coinPackageModel.dart';
import 'package:mindrena/app/data/shopItemModel.dart';
import 'package:quickalert/quickalert.dart';

class ShopController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Observable variables
  var userPoints = 0.obs;
  var userCoins = 0.obs;
  var isLoading = true.obs;
  var isPurchasing = false.obs; // Add this for purchase loading
  var purchasingItemId = ''.obs; // Track which item is being purchased
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

  // Coin purchase packages
  var coinPackages = <CoinPackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeShopItems();
    _initializeCoinPackages();
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
        description: 'Sharp Red Guy',
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
        id: 'avatar_6',
        name: 'Isabella Lane',
        description: 'Ambitious Gray Girl',
        price: 900,
        imageUrl: 'assets/cha8.jpeg',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_7',
        name: 'Nathaniel Blue',
        description: 'Nice Blue Guy',
        price: 0,
        imageUrl: 'assets/cha1.png',
        type: ShopItemType.avatar,
      ),
      ShopItem(
        id: 'avatar_8',
        name: 'Adrian Cole',
        description: 'Smart Orange Guy',
        price: 0,
        imageUrl: 'assets/cha2.png',
        type: ShopItemType.avatar,
      ),
    ];

    // Sticker items
    stickerItems.value = [
      ShopItem(
        id: 'sticker_1',
        name: 'Happy',
        description: 'Happy!',
        price: 100,
        imageUrl: 'assets/happy.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_2',
        name: 'Confused',
        description: 'Confused...',
        price: 150,
        imageUrl: 'assets/confused.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_3',
        name: 'Shocked',
        description: 'So shocked!',
        price: 200,
        imageUrl: 'assets/shocked.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_4',
        name: 'Angry',
        description: 'You\'re angry!',
        price: 120,
        imageUrl: 'assets/angry.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_5',
        name: 'Sad',
        description: 'Sad!',
        price: 100,
        imageUrl: 'assets/sad.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_6',
        name: 'No',
        description: 'No...',
        price: 150,
        imageUrl: 'assets/no.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_7',
        name: 'Blushing',
        description: 'So blushing!',
        price: 200,
        imageUrl: 'assets/blushing.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_8',
        name: 'Mocking',
        description: 'You\'re mocking!',
        price: 120,
        imageUrl: 'assets/mocking.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_9',
        name: 'No',
        description: 'No...',
        price: 150,
        imageUrl: 'assets/no_b.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_10',
        name: 'Angry',
        description: 'So angry!',
        price: 200,
        imageUrl: 'assets/angry_g.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_11',
        name: 'Sad',
        description: 'You\'re Sad!',
        price: 120,
        imageUrl: 'assets/sad_g.png',
        type: ShopItemType.sticker,
      ),
      ShopItem(
        id: 'sticker_12',
        name: 'Yes',
        description: 'Yes!',
        price: 120,
        imageUrl: 'assets/yes.png',
        type: ShopItemType.sticker,
      ),
    ];
  }

  /// Initialize coin packages
  void _initializeCoinPackages() {
    coinPackages.value = [
      CoinPackage(
        id: 'coins_100',
        coins: 100,
        price: 30.0, // 30 THB
        mmkPrice: 2000.0, // 2000 MMK
        originalPrice: 35.0,
        isPopular: false,
      ),
      CoinPackage(
        id: 'coins_500',
        coins: 500,
        price: 120.0, // 120 THB
        mmkPrice: 8000.0, // 8000 MMK
        originalPrice: 150.0,
        isPopular: true,
      ),
      CoinPackage(
        id: 'coins_1000',
        coins: 1000,
        price: 200.0, // 200 THB
        mmkPrice: 15000.0, // 15000 MMK
        originalPrice: 250.0,
        isPopular: false,
      ),
      CoinPackage(
        id: 'coins_2500',
        coins: 2500,
        price: 450.0, // 450 THB
        mmkPrice: 35000.0, // 35000 MMK
        originalPrice: 600.0,
        isPopular: false,
      ),
    ];
  }

  /// Navigate to coin purchase flow
  void buyCoinPackage(CoinPackage package) {
    Get.toNamed('/payment-selection', arguments: {'package': package});
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

  /// Check if a specific item is being purchased
  bool isItemBeingPurchased(String itemId) {
    return isPurchasing.value && purchasingItemId.value == itemId;
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

      // Start loading state
      isPurchasing.value = true;
      purchasingItemId.value = item.id;

      // Show loading dialog
      _showLoadingDialog(item);

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
          // Hide loading dialog
          Get.back();
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

      // Hide loading dialog
      Get.back();

      _showSuccessMessage('${item.name} purchased successfully!');
    } catch (e) {
      print('Error purchasing item: $e');
      // Hide loading dialog if it's showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _showErrorMessage('Failed to purchase item. Please try again.');
    } finally {
      // Reset loading state
      isPurchasing.value = false;
      purchasingItemId.value = '';
    }
  }

  /// Show purchase confirmation dialog
  Future<bool> _showPurchaseConfirmation(ShopItem item) async {
    bool? result = await QuickAlert.show(
      context: Get.context!,
      type: QuickAlertType.confirm,
      title: 'Confirm Purchase',
      text: 'Purchase ${item.name} for ${item.price} coins?',
      confirmBtnText: 'Confirm',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Colors.purple,
      onConfirmBtnTap: () {
        Get.back(result: true);
      },
    );
    return result ?? false; // Return false if result is null
  }

  /// Show loading dialog during purchase
  void _showLoadingDialog(ShopItem item) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissing during purchase
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading animation
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF667eea),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Loading text
                Text(
                  item.type == ShopItemType.avatar
                      ? 'Purchasing Avatar...'
                      : 'Purchasing Sticker...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A47),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  item.type == ShopItemType.avatar
                      ? 'Uploading your new avatar to your profile'
                      : 'Adding sticker to your collection',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Item preview
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            item.type == ShopItemType.avatar
                                ? Icons.person
                                : Icons.emoji_emotions,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
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
