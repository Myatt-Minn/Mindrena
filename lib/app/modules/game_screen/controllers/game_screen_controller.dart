import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mindrena/app/modules/home/controllers/home_controller.dart';

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
  final lastProcessedQuestionIndex = (-1).obs;

  // Track if game has started (to play sound for first question)
  var _gameHasStarted = false;

  // Timer for countdown
  Timer? _questionTimer;
  StreamSubscription<DocumentSnapshot>? _gameSubscription;
  Timer? _timerStartDebounce;
  Timer? _questionMoveDebounce;

  // Audio player for countdown sound
  late AudioPlayer _countdownPlayer;

  // Audio player for game completion sound
  late AudioPlayer _gameCompletePlayer;

  // Track if game completion sound has been played
  var _gameCompleteSoundPlayed = false;

  @override
  void onInit() {
    super.onInit();

    // Initialize countdown audio player
    _countdownPlayer = AudioPlayer();

    // Initialize game complete audio player
    _gameCompletePlayer = AudioPlayer();

    // Clear sent invitations since game is starting
    try {
      final homeController = Get.find<HomeController>();
      homeController.clearSentInvitations();
    } catch (e) {
      // HomeController might not be available, ignore
      print('Could not clear sent invitations in game: $e');
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

  @override
  void onClose() {
    _questionTimer?.cancel();
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
    final previousGameStatus = gameStatus.value;
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

    // Check if game just became active (first question start)
    final gameJustStarted =
        previousGameStatus != 'active' && gameStatus.value == 'active';

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
      lastProcessedQuestionIndex.value =
          -1; // Reset processed question tracking
      print(
        'Question changed from $previousQuestionIndex to ${currentQuestionIndex.value}',
      );

      // Reset timer display for new question
      timeLeft.value = 10;
    }

    // Update current question
    if (questions.isNotEmpty && currentQuestionIndex.value < questions.length) {
      currentQuestion.value = questions[currentQuestionIndex.value];

      // Play countdown sound for new question AFTER setting current question
      if (questionChanged) {
        _playCountdownSound();
      }

      // Play countdown sound when game just starts AFTER setting current question
      if (gameJustStarted && !_gameHasStarted) {
        _gameHasStarted = true;
        print(
          'Game just became active, playing countdown sound for first question',
        );
        _playCountdownSound();
      }

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

        // Check if both players have answered (always check, but respect timing)
        if (gameStatus.value == 'active') {
          // Use a small delay to ensure all state updates are complete
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

      // Update answer in Firestore with explicit question index to ensure proper tracking
      final currentQuestionIdx = currentQuestionIndex.value;

      // First, get current answers to ensure we're updating the right index
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

        // Ensure the answers array is the right length for the current question
        while (userAnswers.length <= currentQuestionIdx) {
          userAnswers.add('-1'); // Placeholder for unanswered questions
        }

        // Set the answer for the current question
        userAnswers[currentQuestionIdx] = answerIndex.toString();

        // Update Firestore with the complete answers array
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
        // Time-based scoring: points equal to remaining seconds
        // Ensure we give at least 1 point for correct answers, even if time is 0
        int pointsEarned = timeLeft.value;
        if (pointsEarned <= 0) {
          pointsEarned = 1; // Minimum 1 point for correct answer
        }
        // Cap maximum points at 10
        pointsEarned = pointsEarned.clamp(1, 10);

        print(
          'Correct answer! Adding $pointsEarned points (based on ${timeLeft.value} seconds remaining)',
        );

        await _firestore.collection('games').doc(gameId.value).update({
          'scores.$userId': FieldValue.increment(pointsEarned),
        });
      }

      print('Answer submitted successfully');

      // Check if both players have answered after a short delay to allow Firestore sync
      Future.delayed(const Duration(milliseconds: 500), () {
        if (gameStatus.value == 'active' && !isMovingToNextQuestion.value) {
          print('Checking if both players answered after answer submission');
          _checkIfBothPlayersAnswered();
        }
      });
    } catch (e) {
      print('Error submitting answer: $e');
      Get.snackbar('Error', 'Failed to submit answer: $e');
      // Reset state on error
      isAnswerSubmitted.value = false;
      selectedAnswer.value = -1;
    }
  }

  void _checkIfBothPlayersAnswered() {
    // Don't proceed if we're already moving to next question or game is not active
    if (isMovingToNextQuestion.value || gameStatus.value != 'active') {
      print(
        'Skipping both players check - isMovingToNextQuestion: ${isMovingToNextQuestion.value}, gameStatus: ${gameStatus.value}',
      );
      return;
    }

    // Ensure we have at least 2 players
    if (playerIds.length < 2) {
      print(
        'Skipping both players check - not enough players: ${playerIds.length}',
      );
      return;
    }

    // Don't check if we've already processed this question
    if (lastProcessedQuestionIndex.value == currentQuestionIndex.value) {
      print(
        'Skipping both players check - already processed question ${currentQuestionIndex.value}',
      );
      return;
    }

    // Check if all players have answered the current question
    bool allPlayersAnswered = true;
    List<String> playersWithAnswers = [];
    List<String> playersWithoutAnswers = [];
    final currentUserId = _auth.currentUser?.uid;

    for (String playerId in playerIds) {
      final playerAnswers = answers[playerId] ?? [];
      // Fix: Check if player has answered the current question specifically
      // The array length should be greater than the current question index
      bool hasAnswered = playerAnswers.length > currentQuestionIndex.value;

      // For the current user, also check if they have locally submitted an answer
      // This handles cases where Firestore hasn't updated yet but the user has submitted
      if (!hasAnswered &&
          playerId == currentUserId &&
          isAnswerSubmitted.value) {
        hasAnswered = true;
        print('Using local submission state for current user: $playerId');
      }

      print(
        'Player $playerId: answers=${playerAnswers.length}, current question=${currentQuestionIndex.value}, hasAnswered=$hasAnswered',
      );

      if (hasAnswered) {
        playersWithAnswers.add(playerId);
      } else {
        playersWithoutAnswers.add(playerId);
        allPlayersAnswered = false;
      }
    }

    print(
      'Question ${currentQuestionIndex.value}: Players with answers: $playersWithAnswers (${playersWithAnswers.length}), without answers: $playersWithoutAnswers (${playersWithoutAnswers.length})',
    );

    if (allPlayersAnswered && playerIds.length >= 2) {
      print(
        'All ${playerIds.length} players have answered question ${currentQuestionIndex.value}, moving to next question early',
      );

      // Mark this question as processed to prevent duplicate processing
      lastProcessedQuestionIndex.value = currentQuestionIndex.value;

      // Cancel the current timer since we're moving early
      _questionTimer?.cancel();

      // Set flag to prevent timer-based movement
      isMovingToNextQuestion.value = true;

      // Move to next question after a brief delay to show answer feedback
      _questionMoveDebounce?.cancel();
      _questionMoveDebounce = Timer(const Duration(milliseconds: 2000), () {
        if (gameStatus.value == 'active') {
          print(
            'Executing early move to next question from both players answered',
          );
          _moveToNextQuestion();
        }
      });
    } else {
      print(
        'Not all players answered yet - waiting for: $playersWithoutAnswers',
      );
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
      // Check if game is already finished to prevent duplicate processing
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
        'finishedAt': FieldValue.serverTimestamp(),
        'statsUpdated': false, // Flag to track if stats have been updated
      });

      // Only update stats once from one client to prevent duplicates
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId != null &&
          playerIds.isNotEmpty &&
          currentUserId == playerIds.first) {
        print('Updating player stats (as first player)');
        await _updatePlayerStats();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to finish game: $e');
    }
  }

  Future<void> _updatePlayerStats() async {
    try {
      // Check if stats have already been updated for this game
      final gameDoc = await _firestore
          .collection('games')
          .doc(gameId.value)
          .get();
      if (gameDoc.exists && gameDoc.data()?['statsUpdated'] == true) {
        print('Stats already updated for this game, skipping');
        return;
      }

      final batch = _firestore.batch();
      final gameRef = _firestore.collection('games').doc(gameId.value);

      // Calculate winner(s) properly
      final allScores = scores.values.toList();
      final maxScore = allScores.isNotEmpty
          ? allScores.reduce((a, b) => a > b ? a : b)
          : 0;

      // Count how many players have the max score (for tie handling)
      final winnersCount = scores.values
          .where((score) => score == maxScore && score > 0)
          .length;
      final isTie = winnersCount > 1;

      print(
        'Max score: $maxScore, Winners count: $winnersCount, Is tie: $isTie',
      );

      for (String playerId in playerIds) {
        final playerScore = scores[playerId] ?? 0;
        final userRef = _firestore.collection('users').doc(playerId);

        // Player wins only if they have the highest score AND it's not a tie
        // OR if it's a tie, they still get a win (you can change this logic if needed)
        final hasWon = playerScore == maxScore && playerScore > 0;

        // Calculate coins reward: half of the points earned in this game
        final coinsEarned = (playerScore / 2).floor();

        print(
          'Player $playerId: score=$playerScore, hasWon=$hasWon, coinsEarned=$coinsEarned',
        );

        // Update basic stats including coins
        batch.update(userRef, {
          'stats.gamesPlayed': FieldValue.increment(1),
          'stats.totalPoints': FieldValue.increment(playerScore),
          'stats.coins': FieldValue.increment(
            coinsEarned,
          ), // Add coins separately
          'currentGameId': FieldValue.delete(),
        });

        // Update wins - in case of tie, both players get a win
        // If you want ties to not count as wins, add: && !isTie
        if (hasWon) {
          batch.update(userRef, {'stats.gamesWon': FieldValue.increment(1)});
          print('Incrementing gamesWon for player $playerId');
        }
      }

      // Mark stats as updated to prevent duplicate updates
      batch.update(gameRef, {'statsUpdated': true});

      await batch.commit();
      print('Player stats updated successfully');
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
      final playerAnswers = answers[playerId] ?? [];

      // Calculate correct answers count
      int correctAnswers = 0;
      for (int j = 0; j < playerAnswers.length && j < questions.length; j++) {
        final userAnswer = int.tryParse(playerAnswers[j]) ?? -1;
        final correctAnswer = questions[j]['correctIndex'] ?? -1;
        if (userAnswer == correctAnswer && userAnswer != -1) {
          correctAnswers++;
        }
      }

      // Calculate accuracy percentage
      final totalAnswered = playerAnswers
          .where((answer) => answer != '-1')
          .length;
      final accuracy = totalAnswered > 0
          ? (correctAnswers / totalAnswered * 100).round()
          : 0;

      finalResults.add({
        'player': player,
        'score': playerScore,
        'correctAnswers': correctAnswers,
        'totalQuestions': questions.length,
        'accuracy': accuracy,
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
    if (currentQuestion.value == null || selectedAnswer.value == -1) {
      return false;
    }
    return selectedAnswer.value == currentQuestion.value!['correctIndex'];
  }

  int get questionProgress {
    if (questions.isEmpty) return 0;
    return ((currentQuestionIndex.value + 1) / questions.length * 100).round();
  }

  // Check if current question is an image-based question (like flags)
  bool get isImageQuestion {
    if (currentQuestion.value == null) return false;
    return currentQuestion.value!.containsKey('image') &&
        currentQuestion.value!['image'] != null &&
        currentQuestion.value!['image'].toString().isNotEmpty;
  }

  // Check if current question is an audio-based question (like sounds)
  bool get isAudioQuestion {
    if (currentQuestion.value == null) return false;
    return currentQuestion.value!.containsKey('audio') &&
        currentQuestion.value!['audio'] != null &&
        currentQuestion.value!['audio'].toString().isNotEmpty;
  }

  // Get the image URL for the current question
  String? get currentQuestionImageUrl {
    if (currentQuestion.value == null || !isImageQuestion) return null;
    return currentQuestion.value!['image'] as String?;
  }

  String? get currentQuestionImageText {
    if (currentQuestion.value == null || !isImageQuestion) return null;
    return currentQuestion.value!['text'] as String?;
  }

  // Get the audio URL for the current question
  String? get currentQuestionAudioUrl {
    if (currentQuestion.value == null || !isAudioQuestion) return null;
    return currentQuestion.value!['audio'] as String?;
  }

  // ============ AUDIO METHODS ============

  /// Play countdown sound when a new question starts
  /// For audio questions (Sounds category), play the question audio instead
  Future<void> _playCountdownSound() async {
    try {
      // For audio questions, play the question audio instead of countdown
      if (isAudioQuestion && currentQuestionAudioUrl != null) {
        print('Playing question audio: $currentQuestionAudioUrl');
        await _countdownPlayer.setUrl(currentQuestionAudioUrl!);
        await _countdownPlayer.setVolume(
          0.8,
        ); // Set volume to 80% for question audio
        await _countdownPlayer.play();
        print('Question audio started playing');
      } else {
        // For other question types, play the countdown sound
        await _countdownPlayer.setAsset('assets/countdown.mp3');
        await _countdownPlayer.setVolume(0.6); // Set volume to 60%
        await _countdownPlayer.play();
        print('Countdown sound played for non-audio question');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  /// Play game complete sound when the game finishes
  Future<void> _playGameCompleteSound() async {
    try {
      await _gameCompletePlayer.setAsset('assets/game_complete.mp3');
      await _gameCompletePlayer.setVolume(0.7); // Set volume to 70%
      await _gameCompletePlayer.play();
      print('Game complete sound played');
    } catch (e) {
      print('Error playing game complete sound: $e');
    }
  }
}
