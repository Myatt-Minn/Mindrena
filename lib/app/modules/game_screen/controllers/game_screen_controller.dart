import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/UserModel.dart';

class GameScreenController extends GetxController {
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

  // Timer for countdown
  Timer? _questionTimer;
  StreamSubscription<DocumentSnapshot>? _gameSubscription;
  Timer? _timerStartDebounce;
  Timer? _questionMoveDebounce;

  @override
  void onInit() {
    super.onInit();

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

  @override
  void onClose() {
    _questionTimer?.cancel();
    _gameSubscription?.cancel();
    _timerStartDebounce?.cancel();
    _questionMoveDebounce?.cancel();
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
      _loadPlayers(); // Reload players when IDs change
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
    gameStatus.value = gameData['status'] ?? 'loading';
    currentQuestionIndex.value = gameData['currentQuestionIndex'] ?? 0;
    questions.value = List<Map<String, dynamic>>.from(
      gameData['questions'] ?? [],
    );

    // Handle question start time for global timer
    if (gameData['questionStartTime'] != null) {
      questionStartTime.value = (gameData['questionStartTime'] as Timestamp)
          .toDate();
      print('Question start time set: ${questionStartTime.value}');
    }

    // Check if we moved to a new question
    final questionChanged = previousQuestionIndex != currentQuestionIndex.value;
    if (questionChanged) {
      // Cancel existing timer when question changes
      _questionTimer?.cancel();
      _questionMoveDebounce?.cancel();

      // Reset state for new question
      isAnswerSubmitted.value = false;
      selectedAnswer.value = -1;
      isMovingToNextQuestion.value = false;
      print(
        'Question changed from $previousQuestionIndex to ${currentQuestionIndex.value}',
      );

      // Reset timer display for new question
      timeLeft.value = 10;
    }

    // Update current question
    if (questions.isNotEmpty && currentQuestionIndex.value < questions.length) {
      currentQuestion.value = questions[currentQuestionIndex.value];

      // Check if current user has answered this question
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final userAnswers = answers[userId] ?? [];
        print(
          'User answers: $userAnswers, Current question index: ${currentQuestionIndex.value}',
        );
        print(
          'Is answer submitted: ${isAnswerSubmitted.value}, Question changed: $questionChanged',
        );

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
            // Only reset if it's actually a new question
            selectedAnswer.value = -1;
            print('Reset state for new question');
          }
        }

        // Start timer for active questions to display countdown
        if (questionStartTime.value != null && gameStatus.value == 'active') {
          final now = DateTime.now();
          final timeSinceStart = now
              .difference(questionStartTime.value!)
              .inSeconds;

          // Start timer for any reasonable timestamp (server controls progression)
          if (timeSinceStart < 15 && timeSinceStart >= -2) {
            print(
              'Starting display timer with question start time: ${questionStartTime.value} (${timeSinceStart}s ago)',
            );

            // Debounce timer starts to prevent multiple rapid starts
            _timerStartDebounce?.cancel();
            _timerStartDebounce = Timer(const Duration(milliseconds: 200), () {
              if (gameStatus.value == 'active') {
                _startQuestionTimer();
              }
            });
          } else {
            print(
              'Question start time too old/future ($timeSinceStart seconds), not starting timer',
            );
          }
        }
      }
    }

    // Check if game is finished
    if (gameStatus.value == 'finished') {
      isGameFinished.value = true;
      _calculateFinalResults();
    }
  }

  // Helper method to compare lists
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
      print('Current user ID: ${_auth.currentUser?.uid}');
    } catch (e) {
      print('Error loading players: $e');
    }
  }

  void _startQuestionTimer() {
    // Don't start timer if game is not active
    if (gameStatus.value != 'active') {
      print(
        'Not starting timer - game not active, status: ${gameStatus.value}',
      );
      return;
    }

    // Don't start if we already have an active timer
    if (_questionTimer?.isActive == true) {
      print('Timer already active, not starting new one');
      return;
    }

    // Cancel any existing timer first
    _questionTimer?.cancel();

    print('Starting display timer for question ${currentQuestionIndex.value}');

    // Start the timer that updates the display every second
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimer();
    });
  }

  void _updateTimer() {
    if (questionStartTime.value == null) {
      timeLeft.value = 10;
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(questionStartTime.value!).inSeconds;
    final remaining = 10 - elapsed;

    // Add safety check - if elapsed time is negative or too large, don't proceed
    if (elapsed < -2 || elapsed > 15) {
      print('Invalid elapsed time: ${elapsed}s, not updating timer');
      return;
    }

    if (remaining > 0) {
      timeLeft.value = remaining;
    } else {
      timeLeft.value = 0;

      // Cancel timer to prevent further calls
      _questionTimer?.cancel();

      // Only proceed if we haven't already started moving to next question
      if (!isMovingToNextQuestion.value && gameStatus.value == 'active') {
        isMovingToNextQuestion.value = true;

        // Auto-submit answer if not submitted
        if (!isAnswerSubmitted.value) {
          print('Auto-submitting answer due to timer expiration');
          submitAnswer(-1);
        }

        // Move to next question after a short delay to allow answer submission
        // Use debouncing to prevent multiple rapid movements
        _questionMoveDebounce?.cancel();
        _questionMoveDebounce = Timer(const Duration(milliseconds: 1500), () {
          if (gameStatus.value == 'active') {
            _moveToNextQuestion();
          }
        });
      }
    }
  }

  Future<void> submitAnswer(int answerIndex) async {
    if (isAnswerSubmitted.value) return;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Set submission state immediately to prevent double submission
      isAnswerSubmitted.value = true;
      selectedAnswer.value = answerIndex;

      print('Submitting answer: $answerIndex for user: $userId');

      // Update answer in Firestore
      await _firestore.collection('games').doc(gameId.value).update({
        'answers.$userId': FieldValue.arrayUnion([answerIndex.toString()]),
      });

      // Calculate score if answer is correct
      final correctIndex = currentQuestion.value?['correctIndex'] ?? -1;
      if (answerIndex == correctIndex) {
        const pointsEarned = 10; // Fixed 10 points per correct answer

        print('Correct answer! Adding $pointsEarned points');

        await _firestore.collection('games').doc(gameId.value).update({
          'scores.$userId': FieldValue.increment(pointsEarned),
        });
      }

      print('Answer submitted successfully');
    } catch (e) {
      print('Error submitting answer: $e');
      Get.snackbar('Error', 'Failed to submit answer: $e');
      // Reset state on error
      isAnswerSubmitted.value = false;
      selectedAnswer.value = -1;
    }
  }

  Future<void> _moveToNextQuestion() async {
    try {
      final nextQuestionIndex = currentQuestionIndex.value + 1;
      print(
        'Moving to next question: $nextQuestionIndex (total: ${questions.length})',
      );

      if (nextQuestionIndex >= questions.length) {
        // Game finished
        print('Game finished - no more questions');
        await _finishGame();
      } else {
        // Move to next question and set new timer
        print('Updating Firestore with new question index: $nextQuestionIndex');
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
      await _firestore.collection('games').doc(gameId.value).update({
        'status': 'finished',
        'finishedAt': FieldValue.serverTimestamp(),
      });

      // Update player statistics
      await _updatePlayerStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to finish game: $e');
    }
  }

  Future<void> _updatePlayerStats() async {
    try {
      final batch = _firestore.batch();

      for (String playerId in playerIds) {
        final playerScore = scores[playerId] ?? 0;
        final userRef = _firestore.collection('users').doc(playerId);

        // Determine if player won (highest score)
        final allScores = scores.values.toList();
        final maxScore = allScores.isNotEmpty
            ? allScores.reduce((a, b) => a > b ? a : b)
            : 0;
        final hasWon = playerScore == maxScore && playerScore > 0;

        batch.update(userRef, {
          'stats.gamesPlayed': FieldValue.increment(1),
          'stats.totalPoints': FieldValue.increment(playerScore),
          'currentGameId': FieldValue.delete(),
        });

        if (hasWon) {
          batch.update(userRef, {'stats.gamesWon': FieldValue.increment(1)});
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error updating player stats: $e');
    }
  }

  void _calculateFinalResults() {
    finalResults.clear();

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final playerId = playerIds[i];
      final playerScore = scores[playerId] ?? 0;

      finalResults.add({
        'player': player,
        'score': playerScore,
        'rank': 1, // Will be calculated after sorting
      });
    }

    // Sort by score descending
    finalResults.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );

    // Assign ranks
    for (int i = 0; i < finalResults.length; i++) {
      finalResults[i]['rank'] = i + 1;
    }
  }

  void exitGame() {
    Get.offAllNamed('/home');
  }

  void playAgain() {
    Get.offNamed('/f-category-selection');
  }

  // Getters for UI
  String get currentUserScore {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      return (scores[userId] ?? 0).toString();
    }
    return '0';
  }

  String get opponentScore {
    final userId = _auth.currentUser?.uid;
    final opponentId = playerIds.firstWhereOrNull((id) => id != userId);
    if (opponentId != null) {
      return (scores[opponentId] ?? 0).toString();
    }
    return '0';
  }

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

  bool get isCorrectAnswer {
    if (currentQuestion.value == null || selectedAnswer.value == -1)
      return false;
    return selectedAnswer.value == currentQuestion.value!['correctIndex'];
  }

  int get questionProgress {
    if (questions.isEmpty) return 0;
    return ((currentQuestionIndex.value + 1) / questions.length * 100).round();
  }
}
