import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/messageModel.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class FriendProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final user = Rxn<UserModel>(); // Reactive variable to hold friend's data
  var currentUser = Rxn<UserModel>(); // Current logged-in user
  var isLoading = true.obs; // To show a loading indicator
  var selectedTab = 0.obs; // For tab selection in profile
  var purchasedAvatars = <Map<String, String>>[].obs;
  var purchasedStickers = <Map<String, String>>[].obs;
  var trophies = <Map<String, String>>[].obs;
  var relationshipStatus = 'unknown'.obs; // Friend relationship status

  @override
  void onInit() async {
    super.onInit();
    final friendData = Get.arguments as UserModel?;
    if (friendData != null) {
      await _loadCurrentUser();
      await fetchFriendProfile(friendData.uid!);
      _updateRelationshipStatus();
    }
    isLoading.value = false;
  }

  /// Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists) {
          currentUser.value = UserModel.fromMap(doc.data()!);
          print('Current user loaded: ${currentUser.value?.username}');
        }
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  /// Update relationship status based on current user and friend data
  void _updateRelationshipStatus() {
    if (currentUser.value == null || user.value == null) {
      relationshipStatus.value = 'unknown';
      return;
    }

    final friendUid = user.value!.uid!;
    final current = currentUser.value!;

    if (current.isFriend(friendUid)) {
      relationshipStatus.value = 'friend';
    } else if (current.hasPendingRequest(friendUid)) {
      relationshipStatus.value = 'pending_received';
    } else if (current.hasSentRequest(friendUid)) {
      relationshipStatus.value = 'pending_sent';
    } else {
      relationshipStatus.value = 'none';
    }

    print(
      'Relationship status with ${user.value?.username}: ${relationshipStatus.value}',
    );
  }

  Future<void> fetchFriendProfile(String friendId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final document = await firestore.collection('users').doc(friendId).get();

      if (document.exists) {
        user.value = UserModel.fromMap(document.data() as Map<String, dynamic>);
        await _loadPurchasedItems();
        _updateRelationshipStatus(); // Update relationship status after fetching
      } else {
        print("Friend does not exist");
      }
    } catch (e) {
      print("Error fetching friend profile: $e");
    }
  }

  /// Load purchased items from Firestore
  Future<void> _loadPurchasedItems() async {
    try {
      if (user.value?.uid == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.value!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        // Load purchased avatars
        purchasedAvatars.value = List<Map<String, String>>.from(
          (userData['purchasedAvatars'] ?? []).map(
            (item) => Map<String, String>.from(item),
          ),
        );

        // Load purchased stickers
        purchasedStickers.value = List<Map<String, String>>.from(
          (userData['purchasedStickers'] ?? []).map(
            (item) => Map<String, String>.from(item),
          ),
        );

        // Load trophies
        trophies.value = [
          if (user.value?.gamesWon != null && user.value!.gamesWon > 0)
            {
              'id': 'first_win',
              'name': 'First Victory',
              'description': 'Won their first game!',
            },
          if (user.value?.gamesWon != null && user.value!.gamesWon >= 10)
            {
              'id': 'win_streak',
              'name': 'Game Master',
              'description': 'Won 10 games!',
            },
          if (user.value?.totalPoints != null &&
              user.value!.totalPoints >= 1000)
            {
              'id': 'point_collector',
              'name': 'Point Collector',
              'description': 'Earned 1000+ points!',
            },
        ];
      }
    } catch (e) {
      print('Error loading purchased items: $e');
    }
  }

  /// Change tab in profile view
  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// Send friend request to the current profile user
  Future<void> sendFriendRequest(BuildContext context) async {
    if (currentUser.value == null || user.value == null) {
      Get.snackbar('Error', 'Unable to send friend request');
      return;
    }

    if (relationshipStatus.value != 'none') {
      Get.snackbar(
        'Info',
        'Friend request already exists or you are already friends',
      );
      return;
    }

    try {
      final batch = _firestore.batch();

      // Add to current user's sent requests
      final currentUserRef = _firestore
          .collection('users')
          .doc(currentUser.value!.uid);
      currentUser.value!.addSentRequest(user.value!.uid!);
      batch.update(currentUserRef, {
        'sentRequests': currentUser.value!.sentRequests,
      });

      // Add to target user's friend requests
      final targetUserRef = _firestore.collection('users').doc(user.value!.uid);
      batch.update(targetUserRef, {
        'friendRequests': FieldValue.arrayUnion([currentUser.value!.uid]),
      });

      await batch.commit();

      // Update relationship status
      relationshipStatus.value = 'pending_sent';
      showTopSnackBar(
        Overlay.of(context),
        animationDuration: Duration(milliseconds: 100),
        snackBarPosition: SnackBarPosition.bottom,
        CustomSnackBar.success(
          message: 'Friend request sent to ${user.value!.username}',
          backgroundColor: Colors.green,

          textStyle: TextStyle(color: Colors.white),
        ),
      );
    } catch (e) {
      print('Error sending friend request: $e');
      Get.snackbar('Error', 'Failed to send friend request');
    }
  }

  /// Create or find conversation and navigate to chat
  Future<void> startChat() async {
    try {
      if (user.value?.uid == null) {
        Get.snackbar('Error', 'Friend profile not loaded');
        return;
      }

      // Get current user from Firebase Auth
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser == null) {
        Get.snackbar('Error', 'Please log in again');
        return;
      }

      // Get current user data from Firestore
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .get();

      if (!currentUserDoc.exists) {
        Get.snackbar('Error', 'User profile not found');
        return;
      }

      final currentUser = UserModel.fromMap(currentUserDoc.data()!);
      final currentUserId = currentUser.uid!;
      final friendUserId = user.value!.uid!;

      // Don't allow chatting with yourself
      if (currentUserId == friendUserId) {
        Get.snackbar('Error', 'Cannot chat with yourself');
        return;
      }

      print('Starting chat between $currentUserId and $friendUserId');

      // Store current user data in GetStorage for ChatController
      final storage = GetStorage();
      await storage.write('user', currentUser.toMap());

      // Check if conversation already exists
      ConversationModel? conversation = await _findExistingConversation(
        currentUserId,
        friendUserId,
      );

      if (conversation == null) {
        print('No existing conversation found, creating new one');
        // Create new conversation
        conversation = await _createNewConversation(currentUser, user.value!);
      } else {
        print('Found existing conversation: ${conversation.id}');
      }

      if (conversation != null) {
        // Navigate to chat with conversation data
        Get.toNamed('/chat', arguments: conversation);
      } else {
        Get.snackbar('Error', 'Failed to create conversation');
      }
    } catch (e) {
      print('Error starting chat: $e');
      Get.snackbar('Error', 'Failed to start chat: ${e.toString()}');
    }
  }

  /// Find existing conversation between two users
  Future<ConversationModel?> _findExistingConversation(
    String user1Id,
    String user2Id,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      print('Searching for conversation between $user1Id and $user2Id');

      // Query for conversation where current user is user1 and friend is user2
      final query1 = await firestore
          .collection('conversations')
          .where('user1_id', isEqualTo: user1Id)
          .where('user2_id', isEqualTo: user2Id)
          .limit(1)
          .get();

      if (query1.docs.isNotEmpty) {
        final doc = query1.docs.first;
        print('Found conversation (query1): ${doc.id}');
        return ConversationModel.fromMap(doc.data(), doc.id);
      }

      // Query for conversation where current user is user2 and friend is user1
      final query2 = await firestore
          .collection('conversations')
          .where('user1_id', isEqualTo: user2Id)
          .where('user2_id', isEqualTo: user1Id)
          .limit(1)
          .get();

      if (query2.docs.isNotEmpty) {
        final doc = query2.docs.first;
        print('Found conversation (query2): ${doc.id}');
        return ConversationModel.fromMap(doc.data(), doc.id);
      }

      print('No existing conversation found');
      return null; // No existing conversation found
    } catch (e) {
      print('Error finding existing conversation: $e');
      return null;
    }
  }

  /// Create new conversation between two users
  Future<ConversationModel?> _createNewConversation(
    UserModel currentUser,
    UserModel friendUser,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      print(
        'Creating new conversation between ${currentUser.uid} and ${friendUser.uid}',
      );

      // Create conversation document
      final conversationRef = firestore.collection('conversations').doc();

      final conversationData = ConversationModel(
        id: conversationRef.id,
        user1Id: currentUser.uid!,
        user2Id: friendUser.uid!,
        user1Name: currentUser.username,
        user2Name: friendUser.username,
        user1Photo: currentUser.avatarUrl,
        user2Photo: friendUser.avatarUrl,
        lastMessage: null,
        lastMessageAt: null,
        unreadCount: 0,
        lastSenderId: null,
      );

      await conversationRef.set(conversationData.toMap());

      print('Successfully created conversation: ${conversationRef.id}');

      return conversationData;
    } catch (e) {
      print('Error creating new conversation: $e');
      return null;
    }
  }
}
