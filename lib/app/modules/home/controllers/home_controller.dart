import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/AdDataModel.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/adOnboardingDialog.dart';

class HomeController extends GetxController {
  var isAdDialogShown = false.obs;
  final GetStorage _storage = GetStorage();

  // Firebase instances for invitation features
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Invitation related variables
  var pendingInvitations = <Map<String, dynamic>>[].obs;
  var sentInvitations = <String>[].obs;
  StreamSubscription? _invitationSubscription;

  @override
  void onInit() async {
    super.onInit();
    // Initialize the controller and check for ads
    await _checkAndShowAdDialog();
    // Start listening for game invitations
    _startInvitationListening();
  }

  @override
  void onClose() {
    _invitationSubscription?.cancel();
    super.onClose();
  }

  // Check if ad dialog should be shown
  Future<void> _checkAndShowAdDialog() async {
    try {
      // Check if this is the user's first time using the app
      bool isFirstTime = _storage.read('is_first_time') ?? true;

      if (isFirstTime) {
        // Mark that the user has opened the app for the first time
        _storage.write('is_first_time', false);
        print('First time user - skipping ad dialog');
        return;
      }

      // Check if dialog was already shown today
      String today = DateTime.now().toIso8601String().split('T')[0];

      // Fetch ads from Firebase
      List<AdData> ads = await _fetchActiveAds();

      if (ads.isNotEmpty && !isAdDialogShown.value) {
        isAdDialogShown.value = true;

        await Get.dialog(
          AdOnboardingDialog(
            ads: ads,
            onComplete: () {
              // Save the date when dialog was shown
              _storage.write('last_ad_shown_date', today);
              isAdDialogShown.value = false;
            },
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Error showing ad dialog: $e');
    }
  }

  // Fetch active ads from Supabase
  Future<List<AdData>> _fetchActiveAds() async {
    try {
      final response =
          await FirebaseFirestore.instance.collection('app_ads').get();

      List<AdData> ads = [];
      for (var item in response.docs) {
        ads.add(AdData.fromJson(item.data()));
      }

      return ads;
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }

  // ============ FRIEND INVITATION METHODS ============

  /// Initialize invitation listening when entering home
  void _startInvitationListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _invitationSubscription = _firestore
        .collection('game_invitations')
        .where('invitedUserId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          // Handle incoming invitations
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final invitation = change.doc.data() as Map<String, dynamic>;
              _handleIncomingInvitation(invitation, change.doc.id);
            } else if (change.type == DocumentChangeType.removed) {
              // Remove invitation from pending list if it was deleted or expired
              pendingInvitations.removeWhere(
                (invitation) => invitation['id'] == change.doc.id,
              );
            }
          }
        });

    // Also clean up expired invitations periodically
    _cleanupExpiredInvitations();
  }

  /// Clean up expired invitations
  void _cleanupExpiredInvitations() {
    Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      pendingInvitations.removeWhere((invitation) {
        final expiresAt = invitation['expiresAt'] as Timestamp?;
        if (expiresAt != null) {
          return expiresAt.toDate().isBefore(now);
        }
        return false;
      });
    });
  }

  /// Handle incoming invitation
  void _handleIncomingInvitation(
    Map<String, dynamic> invitationData,
    String invitationId,
  ) async {
    try {
      // Add invitation to pending list with the document ID
      final invitationWithId = Map<String, dynamic>.from(invitationData);
      invitationWithId['id'] = invitationId;
      pendingInvitations.add(invitationWithId);

      // Get inviter's information
      final inviterDoc =
          await _firestore
              .collection('users')
              .doc(invitationData['inviterUserId'])
              .get();

      if (!inviterDoc.exists) return;

      final inviter = UserModel.fromMap(inviterDoc.data()!);

      // Show invitation dialog
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.people, color: Colors.purple),
              SizedBox(width: 8),
              Text('Game Invitation'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    inviter.avatarUrl.isNotEmpty
                        ? NetworkImage(inviter.avatarUrl)
                        : null,
                child:
                    inviter.avatarUrl.isEmpty
                        ? Icon(Icons.person, size: 30)
                        : null,
              ),
              SizedBox(height: 16),
              Text(
                '${inviter.username} invited you to play!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Category: ${invitationData['category']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                declineInvitation(invitationId);
                Get.back();
              },
              child: Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                acceptInvitation(invitationData, invitationId);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Accept'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      print('Error handling incoming invitation: $e');
    }
  }

  /// Accept a game invitation
  Future<void> acceptInvitation(
    Map<String, dynamic> invitationData,
    String invitationId,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Update invitation status
      await _firestore.collection('game_invitations').doc(invitationId).update({
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Remove from pending invitations
      pendingInvitations.removeWhere(
        (invitation) => invitation['id'] == invitationId,
      );

      // Navigate to lobby with the invited category and friend mode
      final category = invitationData['category'] as String;
      final inviterUsername = invitationData['inviterUsername'] as String;

      Get.toNamed(
        '/lobby',
        arguments: {
          'category': category,
          'gameMode': 'friend_accepted',
          'friendName': inviterUsername,
        },
      );

      Get.snackbar(
        'Invitation Accepted',
        'Joining ${invitationData['inviterUsername']}\'s game!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept invitation: $e');
    }
  }

  /// Decline a game invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      await _firestore.collection('game_invitations').doc(invitationId).update({
        'status': 'declined',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Remove from pending invitations
      pendingInvitations.removeWhere(
        (invitation) => invitation['id'] == invitationId,
      );
    } catch (e) {
      print('Error declining invitation: $e');
    }
  }

  /// Show friend list to invite from anywhere in the app
  Future<void> showInviteFriendsDialog(String category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get current user's friends
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final currentUserData = UserModel.fromMap(userDoc.data()!);
      final friendIds = currentUserData.friends;

      if (friendIds.isEmpty) {
        Get.snackbar(
          'No Friends',
          'Add some friends first to invite them to play!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Get friends data
      final friendsData = <UserModel>[];
      for (String friendId in friendIds) {
        final friendDoc =
            await _firestore.collection('users').doc(friendId).get();
        if (friendDoc.exists) {
          friendsData.add(UserModel.fromMap(friendDoc.data()!));
        }
      }

      // Show custom friends selection dialog
      Get.dialog(
        Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.purple.shade50],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.group_add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Invite Friends',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Choose friends to play $category',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Friends List Section
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child:
                          friendsData.isEmpty
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.people_outline,
                                      size: 60,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Friends Found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add some friends first to\ninvite them to play!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: friendsData.length,
                                itemBuilder: (context, index) {
                                  final friend = friendsData[index];
                                  final isAlreadyInvited = sentInvitations
                                      .contains(friend.uid);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            isAlreadyInvited
                                                ? Colors.green.withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor:
                                                Colors.purple.shade100,
                                            backgroundImage:
                                                friend.avatarUrl.isNotEmpty
                                                    ? NetworkImage(
                                                      friend.avatarUrl,
                                                    )
                                                    : null,
                                            child:
                                                friend.avatarUrl.isEmpty
                                                    ? Icon(
                                                      Icons.person,
                                                      color:
                                                          Colors
                                                              .purple
                                                              .shade400,
                                                      size: 28,
                                                    )
                                                    : null,
                                          ),
                                          if (isAlreadyInvited)
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      title: Text(
                                        friend.username,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        friend.email,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      trailing:
                                          isAlreadyInvited
                                              ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.green
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Invited',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                              : Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.purple.shade400,
                                                      Colors.purple.shade600,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.purple
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    onTap: () {
                                                      Get.back(); // Close dialog
                                                      _sendInvitation(
                                                        friend,
                                                        category,
                                                      );
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(
                                                        12,
                                                      ),
                                                      child: Icon(
                                                        Icons.send,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ),

                  // Footer Section
                  if (friendsData.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Invitations expire in 5 minutes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load friends: $e');
    }
  }

  /// Send invitation to a friend
  Future<void> _sendInvitation(UserModel friend, String category) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get current user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return;

      final currentUserData = UserModel.fromMap(userDoc.data()!);

      // Create invitation document
      await _firestore.collection('game_invitations').add({
        'inviterUserId': user.uid,
        'inviterUsername': currentUserData.username,
        'inviterAvatarUrl': currentUserData.avatarUrl,
        'invitedUserId': friend.uid!,
        'invitedUsername': friend.username,
        'category': category,
        'gameId': '', // Will be filled when lobby is created
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: 5)),
        ), // Expires in 5 minutes
      });

      // Add to sent invitations list
      sentInvitations.add(friend.uid!);

      Get.snackbar(
        'Invitation Sent',
        'Invitation sent to ${friend.username} for $category!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Close the friends dialog and navigate to lobby
      Get.back(); // Close the friends selection dialog

      // Navigate to lobby with friend invitation mode
      Get.toNamed(
        '/lobby',
        arguments: {
          'category': category,
          'gameMode': 'friend_invitation',
          'invitedFriend': friend.username,
        },
      );

      // Auto-remove from sent list after 5 minutes
      Future.delayed(Duration(minutes: 5), () {
        sentInvitations.remove(friend.uid);
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to send invitation: $e');
    }
  }

  /// Get pending invitations count for UI badges
  int get pendingInvitationsCount => pendingInvitations.length;

  /// Check if user has pending invitations
  bool get hasPendingInvitations => pendingInvitations.isNotEmpty;

  /// Quick invite method that can be called from anywhere
  Future<void> quickInviteFriends(String category) async {
    await showInviteFriendsDialog(category);

    // Note: Navigation to lobby happens in _sendInvitation method
    // after successfully sending an invitation
  }

  /// Check if current user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
