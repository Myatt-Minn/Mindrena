import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mindrena/app/modules/home/controllers/home_controller.dart';

import '../../../data/UserModel.dart';

class MemorizeImageGameScreenController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable properties
  final gameId = ''.obs;
  final category = ''.obs;
  final currentQuestionIndex = 0.obs;
  final currentQuestion = Rx<Map<String, dynamic>?>(null);
  final questions = <Map<String, dynamic>>[].obs;
  final playerIds = <String>[].obs;
  final playerStates = <String, String>{}.obs;
  final scores = <String, int>{}.obs;
  final answers = <String, List<String>>{}.obs;
  final gameStatus = 'loading'.obs;
  final selectedAnswer = (-1).obs;
  final isAnswerSubmitted = false.obs;
  final timeLeft = 10.obs;
  final questionStartTime = Rx<DateTime?>(null);
  final showResults = false.obs;
  final players = <UserModel>[].obs;
  final currentPlayerAnswers = <String>[].obs;
  final isGameFinished = false.obs;
  final finalResults = <Map<String, dynamic>>[].obs;
  final isMovingToNextQuestion = false.obs;
  final lastProcessedQuestionIndex = (-1).obs;

  // Memorize Image specific properties
  final isImageDisplayPhase = true.obs;
  final imageDisplayTimeLeft = 7.obs;
  final isQuestionPhase = false.obs;
  final questionPhaseTimeLeft = 10.obs; // Separate timer for question phase
  final isPreloadingImages = true.obs;
  final preloadingProgress = 0.0.obs;
  final preloadedImages =
      <String, bool>{}.obs; // Track which images are preloaded

  // Track if game has started
  var _gameHasStarted = false;

  // Timers
  Timer? _questionTimer;
  Timer? _imageDisplayTimer;
  Timer? _questionPhaseTimer; // Separate timer for question phase
  StreamSubscription<DocumentSnapshot>? _gameSubscription;
  Timer? _timerStartDebounce;
  Timer? _questionMoveDebounce;

  // Audio players
  late AudioPlayer _countdownPlayer;
  late AudioPlayer _gameCompletePlayer;

  // Track if game completion sound has been played
  var _gameCompleteSoundPlayed = false;

  @override
  void onInit() {
    super.onInit();

    // Initialize audio players
    _countdownPlayer = AudioPlayer();
    _gameCompletePlayer = AudioPlayer();

    // Stop background music when game starts
    try {
      final homeController = Get.find<HomeController>();
      homeController.stopBackgroundMusic();
      print('Background music stopped for memorize image game screen');
    } catch (e) {
      print('Could not stop background music: $e');
    }

    // Clear sent invitations since game is starting
    try {
      final homeController = Get.find<HomeController>();
      homeController.clearSentInvitations();
    } catch (e) {
      print('Could not clear sent invitations in memorize image game: $e');
    }

    // Get arguments from route
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      gameId.value = args['gameId'] ?? '';
      category.value = args['category'] ?? '';
    }

    if (gameId.value.isNotEmpty) {
      _initializeGame();
    }
  }

  void exitGame() {
    // Resume background music when returning to home
    try {
      final homeController = Get.find<HomeController>();
      if (homeController.isMusicEnabledInSettings) {
        homeController.resumeBackgroundMusic();
        print('Background music resumed after game exit');
      }
    } catch (e) {
      print('Could not resume background music: $e');
    }

    Get.offAllNamed('/home');
  }

  void playAgain() {
    Get.back();
  }

  @override
  void onClose() {
    _questionTimer?.cancel();
    _imageDisplayTimer?.cancel();
    _questionPhaseTimer?.cancel();
    _gameSubscription?.cancel();
    _timerStartDebounce?.cancel();
    _questionMoveDebounce?.cancel();
    _countdownPlayer.dispose();
    _gameCompletePlayer.dispose();
    super.onClose();
  }

  Future<void> _initializeGame() async {
    try {
      // Listen to game document changes
      _gameSubscription = _firestore
          .collection('games')
          .doc(gameId.value)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists) {
              _updateGameState(snapshot.data()!);
            }
          });

      // Load player data
      await _loadPlayers();
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize game: $e');
    }
  }

  void _updateGameState(Map<String, dynamic> gameData) {
    final newPlayerIds = List<String>.from(gameData['playerIds'] ?? []);

    // Check if player IDs have changed and reload players if needed
    if (!_listsEqual(playerIds, newPlayerIds)) {
      playerIds.value = newPlayerIds;
      _loadPlayers();
    }

    // Handle playerStates
    final rawPlayerStates = Map<String, dynamic>.from(
      gameData['playerStates'] ?? {},
    );
    playerStates.value = rawPlayerStates.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Handle scores
    final rawScores = Map<String, dynamic>.from(gameData['scores'] ?? {});
    scores.value = rawScores.map(
      (key, value) => MapEntry(key, (value as num).toInt()),
    );

    // Handle answers
    final rawAnswers = Map<String, dynamic>.from(gameData['answers'] ?? {});
    answers.value = rawAnswers.map(
      (key, value) => MapEntry(key, List<String>.from(value ?? [])),
    );

    final previousQuestionIndex = currentQuestionIndex.value;
    final previousGameStatus = gameStatus.value;
    gameStatus.value = gameData['status'] ?? 'loading';
    currentQuestionIndex.value = gameData['currentQuestionIndex'] ?? 0;
    questions.value = List<Map<String, dynamic>>.from(
      gameData['questions'] ?? [],
    );

    // Start preloading images if questions are loaded and we haven't started preloading yet
    if (questions.isNotEmpty &&
        isPreloadingImages.value &&
        preloadedImages.isEmpty) {
      _preloadAllImages();
    }

    // Handle question start time
    if (gameData['questionStartTime'] != null) {
      questionStartTime.value = (gameData['questionStartTime'] as Timestamp)
          .toDate();
      print('Question start time set: ${questionStartTime.value}');
    }

    // Check if game just became active
    final gameJustStarted =
        previousGameStatus != 'active' && gameStatus.value == 'active';

    // Check if we moved to a new question
    final questionChanged = previousQuestionIndex != currentQuestionIndex.value;
    if (questionChanged) {
      // Cancel existing timers when question changes
      _questionTimer?.cancel();
      _imageDisplayTimer?.cancel();
      _questionPhaseTimer?.cancel();
      _questionMoveDebounce?.cancel();

      // Reset state for new question
      isAnswerSubmitted.value = false;
      selectedAnswer.value = -1;
      isMovingToNextQuestion.value = false;
      lastProcessedQuestionIndex.value = -1;

      // Reset memorize image specific state
      isImageDisplayPhase.value = true;
      isQuestionPhase.value = false;
      imageDisplayTimeLeft.value = 7;
      questionPhaseTimeLeft.value = 10;

      print(
        'Question changed from $previousQuestionIndex to ${currentQuestionIndex.value}',
      );

      // Reset timer display for new question
      timeLeft.value = 10;
    }

    // Update current question
    if (questions.isNotEmpty && currentQuestionIndex.value < questions.length) {
      currentQuestion.value = questions[currentQuestionIndex.value];

      // Start image display phase for new question
      if (questionChanged) {
        _startImageDisplayPhase();
      }

      // Start image display phase when game just starts
      if (gameJustStarted && !_gameHasStarted) {
        _gameHasStarted = true;
        print('Game just became active, starting image display phase');
        _startImageDisplayPhase();
      }

      // Check if current user has answered this question
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final userAnswers = answers[userId] ?? [];

        if (userAnswers.length > currentQuestionIndex.value) {
          // User has already answered this question
          if (!isAnswerSubmitted.value || questionChanged) {
            isAnswerSubmitted.value = true;
            selectedAnswer.value =
                int.tryParse(userAnswers[currentQuestionIndex.value]) ?? -1;
            print('Set answer from database: ${selectedAnswer.value}');
          }
        } else {
          // User hasn't answered this question yet
          if (questionChanged) {
            selectedAnswer.value = -1;
            print('Reset state for new question');
          }
        }

        // Check if both players have answered (during question phase only)
        if (gameStatus.value == 'active' && isQuestionPhase.value) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (gameStatus.value == 'active' && !isMovingToNextQuestion.value) {
              _checkIfBothPlayersAnswered();
            }
          });
        }
      }
    }

    // Check if game is finished
    if (gameStatus.value == 'finished') {
      isGameFinished.value = true;

      // Play game complete sound once
      if (!_gameCompleteSoundPlayed) {
        _gameCompleteSoundPlayed = true;
        _playGameCompleteSound();
      }

      _calculateFinalResults();
    }
  }

  void _startImageDisplayPhase() {
    if (gameStatus.value != 'active') {
      print('Not starting image display - game not active');
      return;
    }

    print('Starting image display phase for 7 seconds');
    isImageDisplayPhase.value = true;
    isQuestionPhase.value = false;
    imageDisplayTimeLeft.value = 7;

    // Check if current image is preloaded before starting timer
    _waitForCurrentImageThenStartTimer();
  }

  Future<void> _waitForCurrentImageThenStartTimer() async {
    final currentImg = currentQuestion.value?['image'];

    if (currentImg != null) {
      // If image isn't preloaded yet, try to preload it quickly
      if (preloadedImages[currentImg.toString()] != true) {
        print('Current image not preloaded, attempting quick preload...');
        try {
          await _preloadSingleImage(currentImg.toString());
          print('Successfully preloaded current image');
        } catch (e) {
          print('Failed to preload current image: $e');
          // Continue anyway - the image will load when displayed
        }
      } else {
        print('Current image already preloaded');
      }
    }

    // Start the 7-second image display timer
    _imageDisplayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (imageDisplayTimeLeft.value > 0) {
        imageDisplayTimeLeft.value--;
      } else {
        timer.cancel();
        _startQuestionPhase();
      }
    });
  }

  void _startQuestionPhase() {
    print('Starting question phase with 10-second timer');
    isImageDisplayPhase.value = false;
    isQuestionPhase.value = true;
    questionPhaseTimeLeft.value = 10;

    // Play countdown sound for question phase
    _playCountdownSound();

    // Start the question phase timer (independent 10-second countdown)
    _questionPhaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (questionPhaseTimeLeft.value > 0) {
        questionPhaseTimeLeft.value--;
        timeLeft.value = questionPhaseTimeLeft.value; // Update display
      } else {
        timer.cancel();

        if (!isMovingToNextQuestion.value && gameStatus.value == 'active') {
          isMovingToNextQuestion.value = true;

          if (!isAnswerSubmitted.value) {
            print('Auto-submitting answer due to question timer expiration');
            submitAnswer(-1);
          }

          _questionMoveDebounce?.cancel();
          _questionMoveDebounce = Timer(const Duration(milliseconds: 1500), () {
            if (gameStatus.value == 'active') {
              _moveToNextQuestion();
            }
          });
        }
      }
    });
  }

  Future<void> submitAnswer(int answerIndex) async {
    if (isAnswerSubmitted.value || !isQuestionPhase.value) return;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      isAnswerSubmitted.value = true;
      selectedAnswer.value = answerIndex;

      print('Submitting answer: $answerIndex for user: $userId');

      final currentQuestionIdx = currentQuestionIndex.value;

      final gameDoc = await _firestore
          .collection('games')
          .doc(gameId.value)
          .get();
      if (gameDoc.exists) {
        final gameData = gameDoc.data()!;
        final currentAnswers = Map<String, dynamic>.from(
          gameData['answers'] ?? {},
        );
        final userAnswers = List<String>.from(currentAnswers[userId] ?? []);

        while (userAnswers.length <= currentQuestionIdx) {
          userAnswers.add('-1');
        }

        userAnswers[currentQuestionIdx] = answerIndex.toString();

        await _firestore.collection('games').doc(gameId.value).update({
          'answers.$userId': userAnswers,
        });

        print(
          'Updated answers array for question $currentQuestionIdx: $userAnswers',
        );
      }

      // Calculate score if answer is correct
      final correctIndex = currentQuestion.value?['correctIndex'] ?? -1;
      if (answerIndex == correctIndex) {
        const pointsEarned = 10;
        print('Correct answer! Adding $pointsEarned points');

        await _firestore.collection('games').doc(gameId.value).update({
          'scores.$userId': FieldValue.increment(pointsEarned),
        });
      }

      print('Answer submitted successfully');

      Future.delayed(const Duration(milliseconds: 500), () {
        if (gameStatus.value == 'active' && !isMovingToNextQuestion.value) {
          print('Checking if both players answered after answer submission');
          _checkIfBothPlayersAnswered();
        }
      });
    } catch (e) {
      print('Error submitting answer: $e');
      Get.snackbar('Error', 'Failed to submit answer: $e');
      isAnswerSubmitted.value = false;
      selectedAnswer.value = -1;
    }
  }

  // Helper methods (reused from GameScreenController)
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<void> _loadPlayers() async {
    try {
      players.clear();
      for (String playerId in playerIds) {
        final userDoc = await _firestore
            .collection('users')
            .doc(playerId)
            .get();
        if (userDoc.exists) {
          final player = UserModel.fromMap(userDoc.data()!);
          players.add(player);
          print('Loaded player: ${player.username} with ID: ${player.uid}');
        }
      }
      print('Total players loaded: ${players.length}');
    } catch (e) {
      print('Error loading players: $e');
    }
  }

  void _checkIfBothPlayersAnswered() {
    if (isMovingToNextQuestion.value || gameStatus.value != 'active') {
      return;
    }

    if (playerIds.length < 2) {
      return;
    }

    if (lastProcessedQuestionIndex.value == currentQuestionIndex.value) {
      return;
    }

    bool allPlayersAnswered = true;
    final currentUserId = _auth.currentUser?.uid;

    for (String playerId in playerIds) {
      final playerAnswers = answers[playerId] ?? [];
      bool hasAnswered = playerAnswers.length > currentQuestionIndex.value;

      if (!hasAnswered &&
          playerId == currentUserId &&
          isAnswerSubmitted.value) {
        hasAnswered = true;
      }

      if (!hasAnswered) {
        allPlayersAnswered = false;
        break;
      }
    }

    if (allPlayersAnswered && playerIds.length >= 2) {
      print('All players have answered, moving to next question early');
      lastProcessedQuestionIndex.value = currentQuestionIndex.value;
      _questionTimer?.cancel();
      _questionPhaseTimer?.cancel();
      isMovingToNextQuestion.value = true;

      _questionMoveDebounce?.cancel();
      _questionMoveDebounce = Timer(const Duration(milliseconds: 2000), () {
        if (gameStatus.value == 'active') {
          _moveToNextQuestion();
        }
      });
    }
  }

  Future<void> _moveToNextQuestion() async {
    try {
      final nextQuestionIndex = currentQuestionIndex.value + 1;
      print('Moving to next question: $nextQuestionIndex');

      if (nextQuestionIndex >= questions.length) {
        print('Game finished - no more questions');
        await _finishGame();
      } else {
        await _firestore.collection('games').doc(gameId.value).update({
          'currentQuestionIndex': nextQuestionIndex,
          'questionStartTime': FieldValue.serverTimestamp(),
        });
        print('Successfully moved to question $nextQuestionIndex');
      }
    } catch (e) {
      print('Error moving to next question: $e');
    }
  }

  Future<void> _finishGame() async {
    try {
      final gameDoc = await _firestore
          .collection('games')
          .doc(gameId.value)
          .get();
      if (gameDoc.exists && gameDoc.data()?['status'] == 'finished') {
        print('Game already finished, skipping duplicate finish');
        return;
      }

      await _firestore.collection('games').doc(gameId.value).update({
        'status': 'finished',
      });
      print('Game finished successfully');
    } catch (e) {
      print('Error finishing game: $e');
    }
  }

  void _calculateFinalResults() {
    try {
      List<Map<String, dynamic>> results = [];

      for (String playerId in playerIds) {
        final player = players.firstWhereOrNull((p) => p.uid == playerId);
        if (player != null) {
          final score = scores[playerId] ?? 0;
          results.add({'player': player, 'score': score});
        }
      }

      results.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      finalResults.value = results;
    } catch (e) {
      print('Error calculating final results: $e');
    }
  }

  Future<void> _playCountdownSound() async {
    try {
      await _countdownPlayer.setAsset('assets/gameQuestion.mp3');
      await _countdownPlayer.play();
      print('Countdown sound played successfully');
    } catch (e) {
      print('Error playing countdown sound: $e');
    }
  }

  Future<void> _playGameCompleteSound() async {
    try {
      await _gameCompletePlayer.setAsset('assets/gameComplete.mp3');
      await _gameCompletePlayer.play();
      print('Game complete sound played successfully');
    } catch (e) {
      print('Error playing game complete sound: $e');
    }
  }

  // Image preloading functionality
  Future<void> _preloadAllImages() async {
    if (questions.isEmpty) return;

    print('Starting to preload ${questions.length} images...');
    isPreloadingImages.value = true;
    preloadingProgress.value = 0.0;

    final imageUrls = questions
        .where((q) => q['image'] != null && q['image'].toString().isNotEmpty)
        .map((q) => q['image'].toString())
        .toSet()
        .toList(); // Remove duplicates

    if (imageUrls.isEmpty) {
      isPreloadingImages.value = false;
      return;
    }

    final totalImages = imageUrls.length;
    var loadedCount = 0;

    // Create a list of futures for parallel loading with timeout
    final preloadFutures = <Future>[];

    for (final imageUrl in imageUrls) {
      final future = _preloadSingleImage(imageUrl)
          .timeout(
            const Duration(seconds: 10), // 10 second timeout per image
            onTimeout: () {
              print('Timeout preloading image: $imageUrl');
              preloadedImages[imageUrl] = false;
            },
          )
          .then((_) {
            loadedCount++;
            preloadingProgress.value = loadedCount / totalImages;
            print('Preloaded image $loadedCount/$totalImages');
          })
          .catchError((error) {
            loadedCount++;
            preloadingProgress.value = loadedCount / totalImages;
            print('Failed to preload image: $imageUrl - Error: $error');
          });

      preloadFutures.add(future);
    }

    // Wait for all images to complete (successful or failed) with overall timeout
    try {
      await Future.wait(
        preloadFutures,
        eagerError: false,
      ).timeout(const Duration(seconds: 30)); // 30 second overall timeout
    } catch (e) {
      print('Preloading timeout or error: $e');
    }

    isPreloadingImages.value = false;
    preloadingProgress.value = 1.0;

    final successCount = preloadedImages.values.where((v) => v == true).length;
    print(
      'Image preloading completed: $successCount/$totalImages successfully loaded',
    );

    // If very few images loaded successfully, show a warning but continue
    if (successCount < totalImages * 0.5) {
      print(
        'Warning: Only $successCount/$totalImages images preloaded successfully',
      );
    }
  }

  Future<void> _preloadSingleImage(String imageUrl) async {
    try {
      if (preloadedImages[imageUrl] == true) {
        return; // Already preloaded
      }

      // Use Flutter's precacheImage to preload
      await precacheImage(NetworkImage(imageUrl), Get.context!);

      preloadedImages[imageUrl] = true;
    } catch (e) {
      preloadedImages[imageUrl] = false;
      print('Error preloading image $imageUrl: $e');
      rethrow;
    }
  }

  // Check if current question's image is preloaded
  bool get isCurrentImagePreloaded {
    final currentImg = currentQuestion.value?['image'];
    if (currentImg == null) return false;
    return preloadedImages[currentImg.toString()] == true;
  }

  // Skip preloading for poor connections
  void skipPreloading() {
    print('Skipping image preloading due to poor connection');
    isPreloadingImages.value = false;
    preloadingProgress.value = 1.0;

    // Mark all images as "not preloaded" so they load on demand
    for (final question in questions) {
      final imageUrl = question['image'];
      if (imageUrl != null) {
        preloadedImages[imageUrl.toString()] = false;
      }
    }
  }

  // Getters for UI
  UserModel? get currentUser {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return players.firstWhereOrNull((player) => player.uid == userId);
  }

  UserModel? get opponent {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return players.firstWhereOrNull((player) => player.uid != userId);
  }

  String get currentUserScore {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return '0';
    return (scores[userId] ?? 0).toString();
  }

  String get opponentScore {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return '0';
    final opponentId = playerIds.firstWhereOrNull((id) => id != userId);
    if (opponentId == null) return '0';
    return (scores[opponentId] ?? 0).toString();
  }
}
