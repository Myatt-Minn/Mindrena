import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class FriendsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable lists
  var friends = <UserModel>[].obs;
  var friendRequests = <UserModel>[].obs;
  var searchResults = <UserModel>[].obs;

  // Loading states
  var isLoading = false.obs;
  var isSearching = false.obs;

  // Text controller for search
  final TextEditingController searchController = TextEditingController();

  // Current user
  UserModel? currentUser;

  // Stream subscription for real-time updates
  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  // Initialize controller with proper sequence
  Future<void> _initializeController() async {
    await _loadCurrentUser();
    _setupUserListener(); // Set up real-time listener
    await _loadFriends();
    await _loadFriendRequests();
  }

  // Setup real-time listener for user data changes
  void _setupUserListener() {
    final user = _auth.currentUser;
    if (user != null) {
      _userStreamSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              final oldUser = currentUser;
              currentUser = UserModel.fromMap(snapshot.data()!);

              // Check if friend requests changed
              if (oldUser == null ||
                  !_listsEqual(
                    oldUser.friendRequests,
                    currentUser!.friendRequests,
                  )) {
                print('Friend requests changed, reloading...');
                _loadFriendRequests();
              }

              // Check if friends changed
              if (oldUser == null ||
                  !_listsEqual(oldUser.friends, currentUser!.friends)) {
                print('Friends list changed, reloading...');
                _loadFriends();
              }
            }
          });
    }
  }

  // Helper method to compare lists
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  void onClose() {
    searchController.dispose();
    _userStreamSubscription?.cancel();
    super.onClose();
  }

  // Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          currentUser = UserModel.fromMap(doc.data()!);
          print('Current user loaded: ${currentUser?.username}');
          print('Friend requests: ${currentUser?.friendRequests.length ?? 0}');
        }
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  // Load friends list
  Future<void> _loadFriends() async {
    if (currentUser == null) {
      print('Cannot load friends: currentUser is null');
      return;
    }

    try {
      isLoading.value = true;

      if (currentUser!.friends.isEmpty) {
        friends.clear();
        print('No friends to load');
        return;
      }

      final friendDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: currentUser!.friends)
          .get();

      friends.value = friendDocs.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      print('Loaded ${friends.length} friends');
    } catch (e) {
      print('Error loading friends: $e');
      Get.snackbar('Error', 'Failed to load friends');
    } finally {
      isLoading.value = false;
    }
  }

  // Load friend requests
  Future<void> _loadFriendRequests() async {
    if (currentUser == null) {
      print('Cannot load friend requests: currentUser is null');
      return;
    }

    try {
      print('Loading friend requests for user: ${currentUser!.username}');
      print('Friend request IDs: ${currentUser!.friendRequests}');

      if (currentUser!.friendRequests.isEmpty) {
        friendRequests.clear();
        print('No friend requests to load');
        return;
      }

      final requestDocs = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: currentUser!.friendRequests)
          .get();

      friendRequests.value = requestDocs.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      print('Loaded ${friendRequests.length} friend requests');
      for (var request in friendRequests) {
        print('Friend request from: ${request.username}');
      }
    } catch (e) {
      print('Error loading friend requests: $e');
      Get.snackbar('Error', 'Failed to load friend requests');
    }
  }

  // Search for users
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;

      // Search by username (case-insensitive approach)
      // First try with original case
      final QuerySnapshot snapshot1 = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      // Then try with lowercase
      final QuerySnapshot snapshot2 = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
          .where(
            'username',
            isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff',
          )
          .limit(20)
          .get();

      // Then try with uppercase first letter
      final String capitalizedQuery = query.isNotEmpty
          ? query[0].toUpperCase() +
                (query.length > 1 ? query.substring(1).toLowerCase() : '')
          : query;
      final QuerySnapshot snapshot3 = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: capitalizedQuery)
          .where('username', isLessThanOrEqualTo: '$capitalizedQuery\uf8ff')
          .limit(20)
          .get();

      // Combine results and remove duplicates
      Set<String> seenIds = {};
      List<UserModel> allResults = [];

      for (var snapshot in [snapshot1, snapshot2, snapshot3]) {
        for (var doc in snapshot.docs) {
          if (!seenIds.contains(doc.id)) {
            seenIds.add(doc.id);
            final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
            // Additional case-insensitive filtering on the client side
            if (user.username.toLowerCase().contains(query.toLowerCase()) &&
                user.uid != currentUser?.uid) {
              allResults.add(user);
            }
          }
        }
      }

      print('Search results: ${allResults.length} found for query: $query');
      searchResults.value = allResults;
    } catch (e) {
      print('Error searching users: $e');
      Get.snackbar('Error', 'Failed to search users');
    } finally {
      isSearching.value = false;
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(
    UserModel targetUser,
    BuildContext context,
  ) async {
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();

      // Add to current user's sent requests
      final currentUserRef = _firestore
          .collection('users')
          .doc(currentUser!.uid);
      currentUser!.addSentRequest(targetUser.uid!);
      batch.update(currentUserRef, {'sentRequests': currentUser!.sentRequests});

      // Add to target user's friend requests
      final targetUserRef = _firestore.collection('users').doc(targetUser.uid);
      batch.update(targetUserRef, {
        'friendRequests': FieldValue.arrayUnion([currentUser!.uid]),
      });

      await batch.commit();

      showTopSnackBar(
        Overlay.of(context),
        animationDuration: Duration(milliseconds: 100),
        CustomSnackBar.success(
          message: 'Friend request sent to ${targetUser.username}',
          backgroundColor: Colors.green,
          textStyle: TextStyle(color: Colors.white),
        ),
      );
    } catch (e) {
      print('Error sending friend request: $e');
      Get.snackbar('Error', 'Failed to send friend request');
    }
  }

  // Accept friend request
  Future<void> acceptFriendRequest(UserModel requester) async {
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();

      // Add to both users' friends lists
      final currentUserRef = _firestore
          .collection('users')
          .doc(currentUser!.uid);
      currentUser!.addFriend(requester.uid!);
      currentUser!.removeFriendRequest(requester.uid!);
      batch.update(currentUserRef, {
        'friends': currentUser!.friends,
        'friendRequests': currentUser!.friendRequests,
      });

      // Add to requester's friends and remove from sent requests
      final requesterRef = _firestore.collection('users').doc(requester.uid);
      batch.update(requesterRef, {
        'friends': FieldValue.arrayUnion([currentUser!.uid]),
        'sentRequests': FieldValue.arrayRemove([currentUser!.uid]),
      });

      await batch.commit();

      // Refresh lists
      await _loadFriends();
      await _loadFriendRequests();

      Get.snackbar(
        'Success',
        'You are now friends with ${requester.username}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error accepting friend request: $e');
      Get.snackbar('Error', 'Failed to accept friend request');
    }
  }

  // Decline friend request
  Future<void> declineFriendRequest(UserModel requester) async {
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();

      // Remove from current user's friend requests
      final currentUserRef = _firestore
          .collection('users')
          .doc(currentUser!.uid);
      currentUser!.removeFriendRequest(requester.uid!);
      batch.update(currentUserRef, {
        'friendRequests': currentUser!.friendRequests,
      });

      // Remove from requester's sent requests
      final requesterRef = _firestore.collection('users').doc(requester.uid);
      batch.update(requesterRef, {
        'sentRequests': FieldValue.arrayRemove([currentUser!.uid]),
      });

      await batch.commit();

      // Refresh friend requests
      await _loadFriendRequests();

      Get.snackbar(
        'Info',
        'Friend request from ${requester.username} declined',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error declining friend request: $e');
      Get.snackbar('Error', 'Failed to decline friend request');
    }
  }

  // Force reload friend requests (useful for debugging)
  Future<void> reloadFriendRequests() async {
    try {
      print('Force reloading friend requests...');
      await _loadCurrentUser(); // Reload user data first
      await _loadFriendRequests(); // Then reload friend requests
    } catch (e) {
      print('Error force reloading friend requests: $e');
    }
  }

  // Remove friend
  Future<void> removeFriend(UserModel friend) async {
    if (currentUser == null) return;

    try {
      final batch = _firestore.batch();

      // Remove from current user's friends
      final currentUserRef = _firestore
          .collection('users')
          .doc(currentUser!.uid);
      currentUser!.removeFriend(friend.uid!);
      batch.update(currentUserRef, {'friends': currentUser!.friends});

      // Remove from friend's friends list
      final friendRef = _firestore.collection('users').doc(friend.uid);
      batch.update(friendRef, {
        'friends': FieldValue.arrayRemove([currentUser!.uid]),
      });

      await batch.commit();

      // Refresh friends list
      await _loadFriends();

      Get.snackbar(
        'Info',
        'Removed ${friend.username} from friends',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error removing friend: $e');
      Get.snackbar('Error', 'Failed to remove friend');
    }
  }

  // Get relationship status with a user
  String getRelationshipStatus(UserModel user) {
    if (currentUser == null) return 'unknown';

    if (currentUser!.isFriend(user.uid!)) {
      return 'friend';
    } else if (currentUser!.hasPendingRequest(user.uid!)) {
      return 'pending_received';
    } else if (currentUser!.hasSentRequest(user.uid!)) {
      return 'pending_sent';
    } else {
      return 'none';
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      await _loadCurrentUser();
      await _loadFriends();
      await _loadFriendRequests();
      print('Data refreshed successfully');
    } catch (e) {
      print('Error refreshing data: $e');
      Get.snackbar('Error', 'Failed to refresh data');
    } finally {
      isLoading.value = false;
    }
  }
}
