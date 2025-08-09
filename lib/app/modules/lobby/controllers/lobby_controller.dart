import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:quickalert/quickalert.dart';

class LobbyController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // Observable variables
  final String category = Get.arguments ?? 'General Knowledge';
  var isSearching = true.obs;
  var matchmakingEntryId = ''.obs;
  var gameId = ''.obs;
  var players = <UserModel>[].obs;
  var gameStatus = 'waiting'.obs;
  var playerStates = <String, String>{}.obs; // Track ready states

  // Stream subscriptions
  StreamSubscription? _matchmakingSubscription;
  StreamSubscription? _gameSubscription;

  UserModel? get currentUser => players.firstWhereOrNull(
    (player) => player.uid == _auth.currentUser?.uid,
  );

  @override
  void onInit() {
    super.onInit();
    startMatchmaking();
    _showGameMechanicsInfo();
  }

  void _showGameMechanicsInfo() {
    // Check if the user has already seen the game mechanics info
    const String storageKey = 'game_mechanics_info_shown';
    bool hasSeenInfo = _storage.read(storageKey) ?? false;

    if (!hasSeenInfo) {
      // Show the dialog after a slight delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        QuickAlert.show(
          context: Get.context!,
          type: QuickAlertType.info,
          title: 'Game Mechanics',
          text: '''Here's how the quiz game works:

🕐 Timer: You get 10 seconds to answer each question

⏰ Progression: The next question will only appear after the timer hits zero

🎯 Scoring: You earn 10 points for each correct answer

⚠️ Timeout: If the timer runs out and you haven't answered, you get no points

💡 Strategy: Answer quickly to secure your points, but don't rush - accuracy matters!

Good luck and have fun! 🎮''',
          confirmBtnText: 'Got it!',
          confirmBtnColor: Colors.indigo,
          onConfirmBtnTap: () {
            Get.back();
            // Mark that the user has seen this info
            _storage.write(storageKey, true);
          },
        );
      });
    }
  }

  @override
  void onClose() {
    _matchmakingSubscription?.cancel();
    _gameSubscription?.cancel();
    super.onClose();
  }

  Future<void> startMatchmaking() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Add current user to players list first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final currentUserData = UserModel.fromMap(userDoc.data()!);
        players.clear();
        players.add(currentUserData);
      }

      // Check if there's already someone waiting for this category
      final existingEntry = await _firestore
          .collection('matchmaking')
          .where('status', isEqualTo: 'waiting')
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      if (existingEntry.docs.isNotEmpty) {
        // Join existing matchmaking entry
        await _joinExistingMatch(existingEntry.docs.first);
      } else {
        // Create new matchmaking entry
        await _createMatchmakingEntry();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start matchmaking: $e');
    }
  }

  Future<void> _createMatchmakingEntry() async {
    try {
      final user = _auth.currentUser!;

      // Create matchmaking entry
      final entryRef = _firestore.collection('matchmaking').doc();
      await entryRef.set({
        'userId': user.uid,
        'category': category,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'waiting',
      });

      matchmakingEntryId.value = entryRef.id;

      // Listen for matchmaking updates
      _matchmakingSubscription = entryRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final status = data['status'] as String;

          if (status == 'matched') {
            final gameIdFromDoc = data['gameId'] as String?;
            if (gameIdFromDoc != null) {
              gameId.value = gameIdFromDoc;
              _startGameSession();
            }
          }
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to create matchmaking entry: $e');
    }
  }

  Future<void> _joinExistingMatch(DocumentSnapshot existingEntry) async {
    try {
      final user = _auth.currentUser!;
      final existingUserId = existingEntry.data() as Map<String, dynamic>;
      final waitingUserId = existingUserId['userId'] as String;

      // Get the waiting user's data
      final waitingUserDoc = await _firestore
          .collection('users')
          .doc(waitingUserId)
          .get();
      if (waitingUserDoc.exists) {
        final waitingUser = UserModel.fromMap(waitingUserDoc.data()!);
        players.add(waitingUser);
      }

      // Create game immediately
      await _createGame([waitingUserId, user.uid]);

      // Update existing matchmaking entry
      await existingEntry.reference.update({
        'status': 'matched',
        'gameId': gameId.value,
        'matchedUserId': user.uid,
      });

      // Create our own matchmaking entry for tracking
      final ourEntry = _firestore.collection('matchmaking').doc();
      await ourEntry.set({
        'userId': user.uid,
        'category': category,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'matched',
        'gameId': gameId.value,
      });

      matchmakingEntryId.value = ourEntry.id;
      _startGameSession();
    } catch (e) {
      Get.snackbar('Error', 'Failed to join match: $e');
    }
  }

  Future<void> _createGame(List<String> playerIds) async {
    try {
      // Fetch random questions for the category
      final questions = await _getRandomQuestions(category, 10);

      final gameRef = _firestore.collection('games').doc();
      gameId.value = gameRef.id;

      // Initialize player states and scores
      Map<String, dynamic> playerStates = {};
      Map<String, dynamic> scores = {};
      Map<String, dynamic> answers = {};

      for (String playerId in playerIds) {
        playerStates[playerId] = 'waiting';
        scores[playerId] = 0;
        answers[playerId] = [];
      }

      await gameRef.set({
        'playerIds': playerIds,
        'playerStates': playerStates,
        'currentQuestionIndex': 0,
        'questions': questions,
        'answers': answers,
        'scores': scores,
        'category': category,
        'startedAt': FieldValue.serverTimestamp(),
        'finishedAt': null,
        'status': 'waiting',
      });

      // Update users' currentGameId
      final batch = _firestore.batch();
      for (String playerId in playerIds) {
        final userRef = _firestore.collection('users').doc(playerId);
        batch.update(userRef, {'currentGameId': gameId.value});
      }
      await batch.commit();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create game: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getRandomQuestions(
    String category,
    int count,
  ) async {
    try {
      final questionsQuery = await _firestore
          .collection('questions')
          .where('category', isEqualTo: category)
          .get();

      if (questionsQuery.docs.isEmpty) {
        throw Exception('No questions found for category: $category');
      }

      final allQuestions = questionsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['text'],
          'options': data['options'],
          'correctIndex': data['correctIndex'],
        };
      }).toList();

      // Shuffle and take random questions
      allQuestions.shuffle(Random());
      return allQuestions.take(count).toList();
    } catch (e) {
      print('Error fetching questions: $e');
      // Return default questions if fetch fails
      return [
        {
          'id': 'default1',
          'text': 'Sample question for $category',
          'options': ['Option A', 'Option B', 'Option C', 'Option D'],
          'correctIndex': 0,
        },
      ];
    }
  }

  void _startGameSession() {
    isSearching.value = false;
    gameStatus.value = 'waiting';

    // Listen to game updates
    _gameSubscription = _firestore
        .collection('games')
        .doc(gameId.value)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            final status = data['status'] as String;
            gameStatus.value = status;

            // Update players list with current game players
            _updatePlayersFromGame(data);

            if (status == 'active') {
              // Navigate to game screen
              Get.offNamed(
                '/game-screen',
                arguments: {'gameId': gameId.value, 'category': category},
              );
            }
          }
        });
  }

  void _updatePlayersFromGame(Map<String, dynamic> gameData) async {
    try {
      final playerIds = List<String>.from(gameData['playerIds'] ?? []);
      final newPlayers = <UserModel>[];

      for (String playerId in playerIds) {
        final userDoc = await _firestore
            .collection('users')
            .doc(playerId)
            .get();
        if (userDoc.exists) {
          newPlayers.add(UserModel.fromMap(userDoc.data()!));
        }
      }

      players.value = newPlayers;

      // Update player states
      final gamePlayerStates = Map<String, dynamic>.from(
        gameData['playerStates'] ?? {},
      );
      playerStates.value = gamePlayerStates.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (e) {
      print('Error updating players: $e');
    }
  }

  Future<void> setPlayerReady() async {
    try {
      final user = _auth.currentUser;
      if (user == null || gameId.value.isEmpty) return;

      await _firestore.collection('games').doc(gameId.value).update({
        'playerStates.${user.uid}': 'ready',
      });

      // Check if all players are ready
      final gameDoc = await _firestore
          .collection('games')
          .doc(gameId.value)
          .get();
      if (gameDoc.exists) {
        final data = gameDoc.data()!;
        final playerStates = Map<String, dynamic>.from(
          data['playerStates'] ?? {},
        );
        final allReady = playerStates.values.every((state) => state == 'ready');

        if (allReady) {
          await _firestore.collection('games').doc(gameId.value).update({
            'status': 'active',
            'startedAt': FieldValue.serverTimestamp(),
            'questionStartTime':
                FieldValue.serverTimestamp(), // Initialize timer for first question
          });
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set ready state: $e');
    }
  }

  Future<void> cancelPlayerReady() async {
    try {
      final user = _auth.currentUser;
      if (user == null || gameId.value.isEmpty) return;

      await _firestore.collection('games').doc(gameId.value).update({
        'playerStates.${user.uid}': 'waiting',
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel ready state: $e');
    }
  }

  Future<void> leaveLobby() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Cancel subscriptions
      _matchmakingSubscription?.cancel();
      _gameSubscription?.cancel();

      // Clean up matchmaking entry
      if (matchmakingEntryId.value.isNotEmpty) {
        await _firestore
            .collection('matchmaking')
            .doc(matchmakingEntryId.value)
            .update({'status': 'cancelled'});
      }

      // Clean up game if it exists and hasn't started
      if (gameId.value.isNotEmpty) {
        final gameDoc = await _firestore
            .collection('games')
            .doc(gameId.value)
            .get();
        if (gameDoc.exists) {
          final data = gameDoc.data()!;
          final status = data['status'] as String;

          if (status == 'waiting') {
            // Delete the game if it hasn't started
            await _firestore.collection('games').doc(gameId.value).delete();

            // Clear currentGameId from user
            await _firestore.collection('users').doc(user.uid).update({
              'currentGameId': null,
            });
          }
        }
      }

      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave lobby: $e');
      Get.back(); // Go back anyway
    }
  }

  // Helper getters for UI
  String get waitingMessage {
    if (isSearching.value) {
      return 'Searching for players...';
    } else if (gameStatus.value == 'waiting') {
      return 'Waiting for players to get ready...';
    } else {
      return 'Starting game...';
    }
  }

  String get playersCountText {
    return 'Players (${players.length}/2)';
  }

  bool get canStartGame {
    return players.length == 2 && gameStatus.value == 'waiting';
  }

  bool get isCurrentUserReady {
    final user = _auth.currentUser;
    if (user == null) return false;
    return playerStates[user.uid] == 'ready';
  }

  bool isPlayerReady(String playerId) {
    return playerStates[playerId] == 'ready';
  }
}
