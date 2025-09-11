import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/modules/home/controllers/home_controller.dart';
import 'package:quickalert/quickalert.dart';

class LobbyController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // Parse arguments to support both old string format and new map format
  late final String category;
  late final String gameMode;
  late final String? friendName;

  // Observable variables
  var isSearching = true.obs;
  var matchmakingEntryId = ''.obs;
  var gameId = ''.obs;
  var players = <UserModel>[].obs;
  var gameStatus = 'waiting'.obs;
  var playerStates = <String, String>{}.obs; // Track ready states
  var isGameReady = false.obs; // Track if game is ready for interaction

  // Stream subscriptions
  StreamSubscription? _matchmakingSubscription;
  StreamSubscription? _gameSubscription;

  UserModel? get currentUser => players.firstWhereOrNull(
    (player) => player.uid == _auth.currentUser?.uid,
  );

  @override
  void onInit() {
    super.onInit();
    // Stop background music when game starts
    try {
      final homeController = Get.find<HomeController>();
      homeController.stopBackgroundMusic();
      print('Background music stopped for game screen');
    } catch (e) {
      print('Could not stop background music: $e');
    }
    // Parse arguments - support both old string format and new map format
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      category = arguments['category'] ?? 'General Knowledge';
      gameMode = arguments['gameMode'] ?? 'random';
      friendName = arguments['invitedFriend'] ?? arguments['friendName'];
    } else {
      category = arguments?.toString() ?? 'General Knowledge';
      gameMode = 'random';
      friendName = null;
    }

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
          text: '''Welcome to the Quiz Game! 🎉

Here's how it works:

🕐 Timer: You get 10 seconds to answer each question

⏰ Progression: The next question will only appear after the timer hits zero

🎯 Scoring: You earn points equal to the remaining seconds when you answer correctly! 
   • Answer with 8 seconds left = 8 points
   • Answer with 3 seconds left = 3 points
   • Minimum: 1 point, Maximum: 10 points per question

⚠️ Timeout: If the timer runs out and you haven't answered, you get no points

💡 Strategy: Answer quickly AND accurately to maximize your score!

Good luck and have fun! 🎮''',
          confirmBtnText: 'Got it!',
          confirmBtnColor: Colors.purple,
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

    // Clear sent invitations when leaving lobby
    try {
      final homeController = Get.find<HomeController>();
      homeController.clearSentInvitations();
    } catch (e) {
      // HomeController might not be available, ignore
      print('Could not clear sent invitations: $e');
    }

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

      // Add a small delay to ensure all Firestore operations are completed
      await Future.delayed(const Duration(milliseconds: 500));

      _startGameSession();
    } catch (e) {
      Get.snackbar('Error', 'Failed to join match: $e');
    }
  }

  Future<void> _createGame(List<String> playerIds) async {
    try {
      // Generate unique game ID first
      final gameRef = _firestore.collection('games').doc();
      gameId.value = gameRef.id;

      // Use the new deterministic question selection method
      final questions = await _getUniqueQuestionsForGame(
        category,
        10,
        playerIds,
      );

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
        'usedQuestionIds': questions
            .map((q) => q['id'])
            .toList(), // Track used questions
      });

      // Update users' currentGameId and track their used questions
      final batch = _firestore.batch();
      for (String playerId in playerIds) {
        final userRef = _firestore.collection('users').doc(playerId);
        batch.update(userRef, {'currentGameId': gameId.value});

        // Update user's question history to avoid repeats
        final questionIds = questions.map((q) => q['id']).toList();
        batch.update(userRef, {
          'recentQuestions.$category': FieldValue.arrayUnion(questionIds),
        });
      }
      await batch.commit();

      print(
        'Game created with questions: ${questions.map((q) => q['id']).toList()}',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create game: $e');
    }
  }

  // Unique question selection per player to avoid repeats
  Future<List<Map<String, dynamic>>> _getUniqueQuestionsForGame(
    String category,
    int count,
    List<String> playerIds,
  ) async {
    try {
      print(
        'Getting unique questions for players: $playerIds in category: $category',
      );

      // Get all questions for the category - use appropriate collection based on category
      String collectionName;
      if (category == 'Flags' || category == 'PlacesImages') {
        collectionName = 'image_questions';
      } else if (category == 'Sounds') {
        collectionName = 'audio_questions';
      } else if (category == 'Memorize Images' ||
          category == 'MemorizeImage' ||
          category == 'MemorizeVideo' ||
          category == 'MemorizeVideos') {
        collectionName = 'memorize_questions';
      } else {
        collectionName = 'questions';
      }
      print('DEBUG: Using collection: $collectionName for category: $category');

      // Transform category name for database query if needed
      String queryCategory = category;
      if (category == 'MemorizeVideo') {
        queryCategory = 'MemorizeVideos'; // Transform to match database
      }
      print('DEBUG: Querying for category: $queryCategory');

      final questionsQuery = await _firestore
          .collection(collectionName)
          .where('category', isEqualTo: queryCategory)
          .get();

      if (questionsQuery.docs.isEmpty) {
        throw Exception('No questions found for category: $category');
      }

      final allQuestions = questionsQuery.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      print('Total questions available: ${allQuestions.length}');

      // Get recently used questions for all players
      Set<String> recentQuestions = {};
      for (String playerId in playerIds) {
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(playerId)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            final playerRecentQuestions =
                userData['recentQuestions']?[category] as List<dynamic>?;
            if (playerRecentQuestions != null) {
              recentQuestions.addAll(playerRecentQuestions.cast<String>());
            }
          }
        } catch (e) {
          print('Error getting recent questions for player $playerId: $e');
        }
      }

      print('Recent questions to avoid: ${recentQuestions.length}');

      // Filter out recently used questions
      final availableQuestions = allQuestions
          .where((question) => !recentQuestions.contains(question['id']))
          .toList();

      print(
        'Available questions after filtering: ${availableQuestions.length}',
      );

      // If we don't have enough unique questions, clear history and use all
      if (availableQuestions.length < count) {
        print(
          'Not enough unique questions, clearing history and using all questions',
        );
        // Clear recent questions for these players
        final batch = _firestore.batch();
        for (String playerId in playerIds) {
          final userRef = _firestore.collection('users').doc(playerId);
          batch.update(userRef, {'recentQuestions.$category': []});
        }
        await batch.commit();

        // Use all questions with better randomization
        allQuestions.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
        return allQuestions.take(count).toList();
      }

      // Shuffle available questions and select required count
      availableQuestions.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      final selectedQuestions = availableQuestions.take(count).toList();

      print(
        'Selected unique questions: ${selectedQuestions.map((q) => q['id']).toList()}',
      );
      return selectedQuestions;
    } catch (e) {
      print('Error in _getUniqueQuestionsForGame: $e');
      // Fallback to basic random selection
      return await _getRandomQuestionsImproved(category, count);
    }
  }

  // Improved method that ensures better randomization and no duplicates
  Future<List<Map<String, dynamic>>> _getRandomQuestionsImproved(
    String category,
    int count,
  ) async {
    try {
      // Get all questions for the category first - use appropriate collection based on category
      String collectionName;
      if (category == 'Flags' || category == 'PlacesImages') {
        collectionName = 'image_questions';
      } else if (category == 'Sounds') {
        collectionName = 'audio_questions';
      } else if (category == 'Memorize Images' ||
          category == 'MemorizeImage' ||
          category == 'MemorizeVideo' ||
          category == 'MemorizeVideos') {
        collectionName = 'memorize_questions';
      } else {
        collectionName = 'questions';
      }
      print(
        'DEBUG: _getRandomQuestionsImproved using collection: $collectionName for category: $category',
      );

      // Transform category name for database query if needed
      String queryCategory = category;
      if (category == 'MemorizeVideo') {
        queryCategory = 'MemorizeVideos'; // Transform to match database
      }
      print('DEBUG: Querying for category: $queryCategory');

      final questionsQuery = await _firestore
          .collection(collectionName)
          .where('category', isEqualTo: queryCategory)
          .get();

      if (questionsQuery.docs.isEmpty) {
        throw Exception('No questions found for category: $category');
      }

      // Convert to list with proper structure
      final allQuestions = questionsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['text'],
          'options': List<String>.from(data['options'] ?? []),
          'correctIndex': data['correctIndex'] ?? 0,
          'randomSeed': data['randomSeed'] ?? Random().nextDouble(),
          'image':
              data['image'], // Include image field for image-based questions
          'category': data['category'], // Include category for reference
        };
      }).toList();

      print('Total questions available for $category: ${allQuestions.length}');

      // Ensure we have enough unique questions
      if (allQuestions.length < count) {
        print(
          'Warning: Only ${allQuestions.length} questions available, but $count requested',
        );
        // Shuffle and return all available questions
        allQuestions.shuffle(Random());
        return allQuestions.take(allQuestions.length).toList();
      }

      // Use multiple randomization passes for better distribution
      final random = Random();

      // First shuffle based on randomSeed
      allQuestions.sort(
        (a, b) =>
            (a['randomSeed'] as double).compareTo(b['randomSeed'] as double),
      );

      // Then apply additional randomization
      for (int i = 0; i < 3; i++) {
        allQuestions.shuffle(random);
      }

      // Use a time-based seed for additional randomness
      final timeSeed = DateTime.now().millisecondsSinceEpoch;
      final timeRandom = Random(timeSeed);

      // Final selection with time-based randomization
      final selectedQuestions = <Map<String, dynamic>>[];
      final usedIndices = <int>{};

      while (selectedQuestions.length < count &&
          usedIndices.length < allQuestions.length) {
        final randomIndex = timeRandom.nextInt(allQuestions.length);
        if (!usedIndices.contains(randomIndex)) {
          usedIndices.add(randomIndex);
          final question = Map<String, dynamic>.from(allQuestions[randomIndex]);
          // Remove randomSeed from final question data
          question.remove('randomSeed');
          selectedQuestions.add(question);
        }
      }

      print(
        'Selected ${selectedQuestions.length} questions using improved randomization',
      );

      // Log selected question IDs for debugging
      final questionIds = selectedQuestions.map((q) => q['id']).toList();
      print('Selected question IDs: $questionIds');

      // Verify no duplicates
      final uniqueIds = questionIds.toSet();
      if (uniqueIds.length != questionIds.length) {
        print(
          'WARNING: Duplicate questions detected! Falling back to simple method.',
        );
        return await _getRandomQuestionsFallback(category, count);
      }

      return selectedQuestions;
    } catch (e) {
      print('Improved random selection failed: $e');
      return await _getRandomQuestionsFallback(category, count);
    }
  }

  // Fallback method for when improved method fails
  Future<List<Map<String, dynamic>>> _getRandomQuestionsFallback(
    String category,
    int count,
  ) async {
    try {
      // Use appropriate collection based on category
      String collectionName;
      if (category == 'Flags' || category == 'PlacesImages') {
        collectionName = 'image_questions';
      } else if (category == 'Sounds') {
        collectionName = 'audio_questions';
      } else if (category == 'Memorize Images' ||
          category == 'MemorizeImage' ||
          category == 'MemorizeVideo' ||
          category == 'MemorizeVideos') {
        collectionName = 'memorize_questions';
      } else {
        collectionName = 'questions';
      }
      print(
        'DEBUG: _getRandomQuestionsFallback using collection: $collectionName for category: $category',
      );

      // Transform category name for database query if needed
      String queryCategory = category;
      if (category == 'MemorizeVideo') {
        queryCategory = 'MemorizeVideos'; // Transform to match database
      }
      print('DEBUG: Querying for category: $queryCategory');

      final questionsQuery = await _firestore
          .collection(collectionName)
          .where('category', isEqualTo: queryCategory)
          .get();

      if (questionsQuery.docs.isEmpty) {
        throw Exception('No questions found for category: $category');
      }

      final allQuestions = questionsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['text'],
          'options': List<String>.from(data['options'] ?? []),
          'correctIndex': data['correctIndex'] ?? 0,
          'image':
              data['image'], // Include image field for image-based questions
          'category': data['category'], // Include category for reference
        };
      }).toList();

      print('Total questions available for $category: ${allQuestions.length}');

      // Check if we have enough questions
      if (allQuestions.length < count) {
        print(
          'Warning: Only ${allQuestions.length} questions available, but $count requested',
        );
        // Return all available questions if we don't have enough
        allQuestions.shuffle(Random());
        return allQuestions;
      }

      // Use multiple randomization passes for better distribution
      final random = Random();
      final selectedQuestions = <Map<String, dynamic>>[];
      final availableQuestions = List<Map<String, dynamic>>.from(allQuestions);

      // Apply multiple shuffles for better randomization
      for (int i = 0; i < 5; i++) {
        availableQuestions.shuffle(random);
      }

      // Use Fisher-Yates shuffle algorithm for maximum randomness
      for (int i = availableQuestions.length - 1; i > 0; i--) {
        final j = random.nextInt(i + 1);
        final temp = availableQuestions[i];
        availableQuestions[i] = availableQuestions[j];
        availableQuestions[j] = temp;
      }

      // Select questions without replacement
      for (int i = 0; i < count && i < availableQuestions.length; i++) {
        selectedQuestions.add(availableQuestions[i]);
      }

      print(
        'Selected ${selectedQuestions.length} random questions for game (fallback method)',
      );

      // Log the selected question IDs for debugging
      final questionIds = selectedQuestions.map((q) => q['id']).toList();
      print('Selected question IDs: $questionIds');

      // Verify no duplicates
      final uniqueIds = questionIds.toSet();
      if (uniqueIds.length != questionIds.length) {
        print('ERROR: Duplicate questions in fallback method!');
        // Remove duplicates manually
        final uniqueQuestions = <Map<String, dynamic>>[];
        final seenIds = <String>{};
        for (final question in selectedQuestions) {
          final id = question['id'] as String;
          if (!seenIds.contains(id)) {
            seenIds.add(id);
            uniqueQuestions.add(question);
          }
        }
        return uniqueQuestions.take(count).toList();
      }

      return selectedQuestions;
    } catch (e) {
      print('Error fetching questions (fallback): $e');
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
              // Stop background music before navigating to game
              try {
                final homeController = Get.find<HomeController>();
                homeController.stopBackgroundMusic();
                print('Background music stopped before game start');
              } catch (e) {
                print('Could not stop background music: $e');
              }

              // Navigate to appropriate game screen based on category
              String routeName;
              if (category == 'Memorize Images' ||
                  category == 'MemorizeImages' ||
                  category == 'MemorizeImage' ||
                  category == 'MemorizeVideos' ||
                  category == 'MemorizeVideo' ||
                  category == 'Memorize Videos') {
                routeName = '/memorize-image-game-screen';
              } else {
                routeName = '/game-screen';
              }

              Get.offNamed(
                routeName,
                arguments: {'gameId': gameId.value, 'category': category},
              );
            }
          }
        });

    // Check initial game readiness after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkGameReadiness();
    });
  }

  Future<void> _checkGameReadiness() async {
    try {
      final user = _auth.currentUser;
      if (user == null || gameId.value.isEmpty) return;

      final gameDoc = await _firestore
          .collection('games')
          .doc(gameId.value)
          .get();

      if (gameDoc.exists) {
        final data = gameDoc.data()!;
        final playerIds = List<String>.from(data['playerIds'] ?? []);
        final gamePlayerStates = Map<String, dynamic>.from(
          data['playerStates'] ?? {},
        );

        final isUserInGame = playerIds.contains(user.uid);
        final hasPlayerState = gamePlayerStates.containsKey(user.uid);
        isGameReady.value = isUserInGame && hasPlayerState;

        print(
          'Game readiness check: isUserInGame=$isUserInGame, hasPlayerState=$hasPlayerState, gameReady=${isGameReady.value}',
        );
      }
    } catch (e) {
      print('Error checking initial game readiness: $e');
    }
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

      // Check if current user is properly set up in the game
      final user = _auth.currentUser;
      if (user != null) {
        final isUserInGame = playerIds.contains(user.uid);
        final hasPlayerState = gamePlayerStates.containsKey(user.uid);
        isGameReady.value = isUserInGame && hasPlayerState;
      }
    } catch (e) {
      print('Error updating players: $e');
      isGameReady.value = false;
    }
  }

  Future<void> setPlayerReady() async {
    try {
      final user = _auth.currentUser;
      if (user == null || gameId.value.isEmpty) {
        print('Cannot set ready: user is null or gameId is empty');
        return;
      }

      // Check if game is ready for interaction
      if (!isGameReady.value) {
        print('Game not ready for interaction yet, please wait...');
        return;
      }

      // Now safe to update ready state
      await _firestore.collection('games').doc(gameId.value).update({
        'playerStates.${user.uid}': 'ready',
      });

      // Re-fetch to check if all players are ready
      final updatedGameDoc = await _firestore
          .collection('games')
          .doc(gameId.value)
          .get();

      if (updatedGameDoc.exists) {
        final updatedData = updatedGameDoc.data()!;
        final playerStates = Map<String, dynamic>.from(
          updatedData['playerStates'] ?? {},
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
      print('Error setting ready state: $e');
      // Don't show error snackbar to user for this race condition
      // The operation will be retried when they press ready again
    }
  }

  Future<void> cancelPlayerReady() async {
    try {
      final user = _auth.currentUser;
      if (user == null || gameId.value.isEmpty) {
        print('Cannot cancel ready: user is null or gameId is empty');
        return;
      }

      // Check if game is ready for interaction
      if (!isGameReady.value) {
        print('Game not ready for interaction yet');
        return;
      }

      await _firestore.collection('games').doc(gameId.value).update({
        'playerStates.${user.uid}': 'waiting',
      });
    } catch (e) {
      print('Error canceling ready state: $e');
      // Don't show error snackbar to user
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
