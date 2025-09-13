import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mindrena/app/data/AdDataModel.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/adOnboardingDialog.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController
  var isAdDialogShown = false.obs;
  final GetStorage _storage = GetStorage();

  // Firebase instances for invitation features
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Invitation related variables
  var pendingInvitations = <Map<String, dynamic>>[].obs;
  var sentInvitations = <String>[].obs;
  StreamSubscription? _invitationSubscription;

  // Audio player for background music
  late AudioPlayer _audioPlayer;
  var isMusicEnabled = true.obs;
  var isMusicPlaying = false.obs;

  @override
  void onInit() async {
    super.onInit();

    // Initialize audio player
    _audioPlayer = AudioPlayer();

    // Load music preferences from storage
    final storedValue = _storage.read('music_enabled');
    print('Stored music preference: $storedValue');
    isMusicEnabled.value = storedValue ?? true;
    print('Music enabled after loading: ${isMusicEnabled.value}');
    // Initialize the controller and check for ads
    await _checkAndShowAdDialog();

    // Start listening for game invitations
    _startInvitationListening();

    // Start background music if enabled
    if (isMusicEnabled.value) {
      await _startBackgroundMusic();
    }
  }

  @override
  void onClose() {
    _invitationSubscription?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  // Check if ad dialog should be shown
  Future<void> _checkAndShowAdDialog() async {
    try {
      // Check if this is the user's first time using the app
      bool isFirstTime = _storage.read('is_first_time') ?? true;

      if (isFirstTime) {
        _storage.write('is_first_time', false);
        print('First time user - skipping ad dialog');
        return;
      }

      // Current date in yyyy-MM-dd format
      String today = DateTime.now().toIso8601String().split('T')[0];

      // Check last date the ad was shown
      String? lastShownDate = _storage.read('last_ad_shown_date');

      if (lastShownDate == today) {
        print('Ad already shown today - skipping');
        return;
      }

      // Fetch ads from Firebase
      List<AdData> ads = await _fetchActiveAds();

      if (ads.isNotEmpty && !isAdDialogShown.value) {
        isAdDialogShown.value = true;

        await Get.dialog(
          AdOnboardingDialog(
            ads: ads,
            onComplete: () {
              // Save today's date so we don't show again today
              _storage.write('last_ad_shown_date', today);
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
      final response = await FirebaseFirestore.instance
          .collection('app_ads')
          .get();

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

    // Listen for incoming invitations
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

    // Listen for sent invitations status changes
    _firestore
        .collection('game_invitations')
        .where('inviterUserId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified ||
                change.type == DocumentChangeType.removed) {
              final invitation = change.doc.data();
              if (invitation != null) {
                final status = invitation['status'] as String;
                final invitedUserId = invitation['invitedUserId'] as String;

                // Remove from sent invitations if declined, expired, or accepted
                if (status == 'declined' ||
                    status == 'expired' ||
                    status == 'accepted') {
                  sentInvitations.remove(invitedUserId);
                }
              }
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

      // Clean up pending invitations
      pendingInvitations.removeWhere((invitation) {
        final expiresAt = invitation['expiresAt'] as Timestamp?;
        if (expiresAt != null) {
          return expiresAt.toDate().isBefore(now);
        }
        return false;
      });

      // Clean up expired sent invitations by checking Firestore
      _cleanupExpiredSentInvitations();
    });
  }

  /// Clean up expired sent invitations from Firestore
  Future<void> _cleanupExpiredSentInvitations() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final now = Timestamp.now();

      // Query for expired invitations sent by current user
      final expiredInvitations = await _firestore
          .collection('game_invitations')
          .where('inviterUserId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isLessThan: now)
          .get();

      // Update expired invitations and clear from sent list
      for (var doc in expiredInvitations.docs) {
        final data = doc.data();
        final invitedUserId = data['invitedUserId'] as String;

        // Update status to expired
        await doc.reference.update({
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
        });

        // Remove from sent invitations list
        sentInvitations.remove(invitedUserId);
      }
    } catch (e) {
      print('Error cleaning up expired sent invitations: $e');
    }
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
      final inviterDoc = await _firestore
          .collection('users')
          .doc(invitationData['inviterUserId'])
          .get();

      if (!inviterDoc.exists) return;

      final inviter = UserModel.fromMap(inviterDoc.data()!);

      // Show modern invitation dialog
      Get.dialog(
        Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 350),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.purple.shade50,
                    Colors.blue.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with animated gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.purple.shade600, Colors.blue.shade600],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.celebration,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Game Invitation!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'You\'ve been challenged!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content with avatar and details
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Enhanced avatar with glow effect
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.purple.shade100,
                                backgroundImage: inviter.avatarUrl.isNotEmpty
                                    ? NetworkImage(inviter.avatarUrl)
                                    : null,
                                child: inviter.avatarUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.purple.shade400,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Inviter name with style
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.1),
                                Colors.blue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            inviter.username,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'wants to challenge you!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Category display with icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                invitationData['category'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action buttons with modern style
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: TextButton.icon(
                                  onPressed: () {
                                    declineInvitation(invitationId);
                                    Get.back();
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Decline',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green.shade500,
                                      Colors.green.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    acceptInvitation(
                                      invitationData,
                                      invitationId,
                                    );
                                    Get.back();
                                  },
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Accept',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Expiry timer display
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 14,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Expires in 5 minutes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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

      // Clear the invitation from the inviter's sent list
      final inviterUserId = invitationData['inviterUserId'] as String;
      _notifyInviterOfAcceptance(inviterUserId, user.uid);

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

  /// Notify inviter that invitation was accepted (clear from their sent list)
  void _notifyInviterOfAcceptance(String inviterUserId, String invitedUserId) {
    // If the current user is the inviter, remove from sent invitations
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == inviterUserId) {
      sentInvitations.remove(invitedUserId);
    }
  }

  /// Decline a game invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      // Get invitation data before updating to know who sent it
      final invitationDoc = await _firestore
          .collection('game_invitations')
          .doc(invitationId)
          .get();

      if (invitationDoc.exists) {
        final invitationData = invitationDoc.data() as Map<String, dynamic>;
        final inviterUserId = invitationData['inviterUserId'] as String;

        // Update invitation status
        await _firestore
            .collection('game_invitations')
            .doc(invitationId)
            .update({
              'status': 'declined',
              'respondedAt': FieldValue.serverTimestamp(),
            });

        // Remove from pending invitations
        pendingInvitations.removeWhere(
          (invitation) => invitation['id'] == invitationId,
        );

        // Clear the invitation from the inviter's sent list
        // (This helps the inviter know they can invite again)
        _notifyInviterOfDecline(inviterUserId, invitationData['invitedUserId']);
      }
    } catch (e) {
      print('Error declining invitation: $e');
    }
  }

  /// Notify inviter that invitation was declined (clear from their sent list)
  void _notifyInviterOfDecline(String inviterUserId, String invitedUserId) {
    // If the current user is the inviter, remove from sent invitations
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid == inviterUserId) {
      sentInvitations.remove(invitedUserId);
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
        final friendDoc = await _firestore
            .collection('users')
            .doc(friendId)
            .get();
        if (friendDoc.exists) {
          friendsData.add(UserModel.fromMap(friendDoc.data()!));
        }
      }

      // Show modern custom friends selection dialog
      Get.dialog(
        Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 650),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.purple.shade50,
                    Colors.blue.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced Header Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,

                        colors: [Colors.purple.shade600, Colors.blue.shade600],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.people_alt,
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
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Enhanced Friends List Section
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: friendsData.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade100,
                                        Colors.grey.shade200,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    Icons.people_outline,
                                    size: 50,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No Friends Yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add some friends first to\ninvite them to epic battles!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.blue.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.back();
                                      Get.toNamed('/friends');
                                    },
                                    icon: const Icon(
                                      Icons.person_add,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Find Friends',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                // Friends counter header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.withOpacity(0.1),
                                        Colors.blue.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.purple.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.group,
                                        color: Colors.purple.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${friendsData.length} Friends Available',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              size: 12,
                                              color: Colors.orange.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '5min',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Enhanced friends list
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: friendsData.length,
                                    itemBuilder: (context, index) {
                                      final friend = friendsData[index];
                                      final isAlreadyInvited = sentInvitations
                                          .contains(friend.uid);

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isAlreadyInvited
                                                ? Colors.green.withOpacity(0.4)
                                                : Colors.grey.withOpacity(0.2),
                                            width: isAlreadyInvited ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isAlreadyInvited
                                                  ? Colors.green.withOpacity(
                                                      0.1,
                                                    )
                                                  : Colors.black.withOpacity(
                                                      0.05,
                                                    ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                          leading: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.purple.withOpacity(
                                                        0.1,
                                                      ),
                                                      Colors.blue.withOpacity(
                                                        0.1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage:
                                                      friend
                                                          .avatarUrl
                                                          .isNotEmpty
                                                      ? NetworkImage(
                                                          friend.avatarUrl,
                                                        )
                                                      : null,
                                                  child:
                                                      friend.avatarUrl.isEmpty
                                                      ? Icon(
                                                          Icons.person,
                                                          color: Colors
                                                              .purple
                                                              .shade400,
                                                          size: 30,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                              if (isAlreadyInvited)
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 14,
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
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.email_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    friend.email,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          trailing: isAlreadyInvited
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.green.shade400,
                                                        Colors.green.shade600,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Sent',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
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
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.purple
                                                            .withOpacity(0.4),
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
                                                            16,
                                                          ),
                                                      onTap: () {
                                                        _sendInvitation(
                                                          friend,
                                                          category,
                                                        );
                                                      },
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                          14,
                                                        ),
                                                        child: Icon(
                                                          Icons.sports_esports,
                                                          color: Colors.white,
                                                          size: 22,
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
                              ],
                            ),
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

      // Auto-remove from sent list after 5 minutes (backup cleanup)
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

  /// Clear sent invitations (call this when leaving lobby or game ends)
  void clearSentInvitations() {
    sentInvitations.clear();
  }

  /// Clear specific sent invitation
  void clearSentInvitation(String friendUid) {
    sentInvitations.remove(friendUid);
  }

  /// Clear all invitation data (useful for logout or app reset)
  void clearAllInvitationData() {
    pendingInvitations.clear();
    sentInvitations.clear();
    _invitationSubscription?.cancel();
  }

  // ============ BACKGROUND MUSIC METHODS ============

  /// Start playing background music
  Future<void> _startBackgroundMusic() async {
    try {
      await _audioPlayer.setAsset('assets/background_music.mp3');
      await _audioPlayer.setLoopMode(LoopMode.all);
      await _audioPlayer.setVolume(0.2); // Set volume to 20%
      await _audioPlayer.play();
      isMusicPlaying.value = true;

      print('Background music started successfully');
    } catch (e) {
      print('Error starting background music: $e');
      isMusicPlaying.value = false;
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _audioPlayer.stop();
      isMusicPlaying.value = false;
      print('Background music stopped');
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _audioPlayer.pause();
      isMusicPlaying.value = false;
      print('Background music paused');
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    try {
      await _audioPlayer.play();
      isMusicPlaying.value = true;
      print('Background music resumed');
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  /// Set background music enabled/disabled state
  Future<void> setMusicEnabled(bool enabled) async {
    print('Setting music enabled to: $enabled');

    if (enabled == isMusicEnabled.value) {
      print('Music state already matches requested state');
      return; // No change needed
    }

    isMusicEnabled.value = enabled;

    if (enabled) {
      await _startBackgroundMusic();
      print('Music started');
    } else {
      await stopBackgroundMusic();
      print('Music stopped');
    }

    // Save preference to storage
    await _storage.write('music_enabled', enabled);
    print('Saved music preference: $enabled');

    // Verify storage
    final savedValue = _storage.read('music_enabled');
    print('Verified saved value: $savedValue');
  }

  /// Toggle background music on/off
  Future<void> toggleBackgroundMusic() async {
    await setMusicEnabled(!isMusicEnabled.value);
  }

  /// Set background music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      print('Music volume set to: ${volume.clamp(0.0, 1.0)}');
    } catch (e) {
      print('Error setting music volume: $e');
    }
  }

  /// Check if music is currently playing
  bool get isMusicCurrentlyPlaying => isMusicPlaying.value;

  /// Check if music is enabled in settings
  bool get isMusicEnabledInSettings => isMusicEnabled.value;

  /// Force reload music settings from storage (useful for debugging)
  void reloadMusicSettings() {
    final storedValue = _storage.read('music_enabled');
    print(
      'Reloading music settings. Stored: $storedValue, Current: ${isMusicEnabled.value}',
    );

    if (storedValue != null) {
      isMusicEnabled.value = storedValue;
      print('Updated music enabled to: ${isMusicEnabled.value}');
    }
  }
}
