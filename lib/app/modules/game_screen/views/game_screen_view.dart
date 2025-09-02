import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/game_screen_controller.dart';

class GameScreenView extends GetView<GameScreenController> {
  const GameScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen Lottie background
          Positioned.fill(
            child: Lottie.asset(
              'assets/gameBackground.json',
              fit: BoxFit.cover,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.purple.shade50,
                        Colors.purple.shade50,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Semi-transparent overlay for better content readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Obx(() {
              if (controller.isGameFinished.value) {
                return _buildGameResults();
              }
              return _buildGameContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildProgressBar(),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.currentQuestion.value == null) {
              return _buildLoadingState();
            }
            return _buildQuestionSection();
          }),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlayerInfo(true),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Obx(
                  () => Text(
                    '${controller.timeLeft.value}s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.timeLeft.value <= 3
                          ? Colors.red.shade600
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              _buildPlayerInfo(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(bool isCurrentUser) {
    return Obx(() {
      final player = isCurrentUser
          ? controller.currentUser
          : controller.opponent;
      final score = isCurrentUser
          ? controller.currentUserScore
          : controller.opponentScore;

      if (player == null) {
        return _buildShimmerPlayerInfo();
      }

      return Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            backgroundImage: player.avatarUrl.isNotEmpty
                ? NetworkImage(player.avatarUrl)
                : null,
            child: player.avatarUrl.isEmpty
                ? Icon(Icons.person, color: Colors.blue.shade600, size: 30)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            player.username,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentUser
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmerPlayerInfo() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.white),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  'Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Obx(
                () => Text(
                  '${controller.questionProgress}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => LinearProgressIndicator(
              value: controller.questionProgress / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade300),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuestionCard(),
          const SizedBox(height: 16),
          Expanded(child: _buildAnswerOptions()),
          if (controller.isAnswerSubmitted.value) _buildAnswerFeedback(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final question = controller.currentQuestion.value;
        if (question == null) return const SizedBox();

        // Check if this is a memorize images question
        if (controller.category.value == 'Memorize Images' &&
            controller.isImageQuestion) {
          return Column(
            children: [
              Text(
                "Memorize the image below. You'll be asked about it!",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildImageQuestion(),
            ],
          );
        } else if (controller.isImageQuestion) {
          return _buildImageQuestion();
        } else if (controller.isAudioQuestion) {
          return Text("Make sure to up the volume. What does it sounds like?");
        } else {
          return _buildTextQuestion();
        }
      }),
    );
  }

  Widget _buildTextQuestion() {
    return Obx(() {
      final question = controller.currentQuestion.value;
      if (question == null) return const SizedBox();

      return Text(
        question['text'] ?? '',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      );
    });
  }

  // ...existing code...
  Widget _buildImageQuestion() {
    return Obx(() {
      final imageUrl = controller.currentQuestionImageUrl;
      final imageText = controller.currentQuestionImageText;
      if (imageUrl == null) return const SizedBox();

      return Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 150, maxWidth: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade400,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (imageText != null && imageText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              imageText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    });
  }
  // ...existing

  Widget _buildAnswerOptions() {
    return Obx(() {
      final question = controller.currentQuestion.value;
      if (question == null) return const SizedBox();

      final options = List<String>.from(question['options'] ?? []);

      return ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index) {
          return _buildAnswerOption(index, options[index]);
        },
      );
    });
  }

  Widget _buildAnswerOption(int index, String option) {
    return Obx(() {
      final isSelected = controller.selectedAnswer.value == index;
      final isAnswerSubmitted = controller.isAnswerSubmitted.value;
      final correctIndex =
          controller.currentQuestion.value?['correctIndex'] ?? -1;
      final isCorrect = index == correctIndex;

      Color? backgroundColor;
      Color? borderColor;
      Color? textColor;

      if (isAnswerSubmitted) {
        if (isCorrect) {
          backgroundColor = Colors.green.shade50;
          borderColor = Colors.green.shade300;
          textColor = Colors.green.shade700;
        } else if (isSelected && !isCorrect) {
          backgroundColor = Colors.red.shade50;
          borderColor = Colors.red.shade300;
          textColor = Colors.red.shade700;
        } else {
          backgroundColor = Colors.grey.shade50;
          borderColor = Colors.grey.shade300;
          textColor = Colors.grey.shade600;
        }
      } else {
        if (isSelected) {
          backgroundColor = Colors.blue.shade50;
          borderColor = Colors.blue.shade300;
          textColor = Colors.blue.shade700;
        } else {
          backgroundColor = Colors.white.withOpacity(0.95);
          borderColor = Colors.grey.shade300;
          textColor = Colors.black87;
        }
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAnswerSubmitted
                ? null
                : () {
                    controller.submitAnswer(index);
                  },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected || (isAnswerSubmitted && isCorrect)
                          ? borderColor
                          : Colors.transparent,
                      border: Border.all(color: borderColor),
                    ),
                    child: isSelected || (isAnswerSubmitted && isCorrect)
                        ? Icon(
                            isAnswerSubmitted && isCorrect
                                ? Icons.check
                                : isAnswerSubmitted && isSelected && !isCorrect
                                ? Icons.close
                                : Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: borderColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAnswerFeedback() {
    return Obx(() {
      if (!controller.isAnswerSubmitted.value) return const SizedBox();

      // Check if both players have answered
      bool bothPlayersAnswered = true;
      for (String playerId in controller.playerIds) {
        final playerAnswers = controller.answers[playerId] ?? [];
        if (playerAnswers.length <= controller.currentQuestionIndex.value) {
          bothPlayersAnswered = false;
          break;
        }
      }

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.isCorrectAnswer
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: controller.isCorrectAnswer
                    ? Colors.green.shade300
                    : Colors.red.shade300,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      controller.isCorrectAnswer
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: controller.isCorrectAnswer
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        controller.isCorrectAnswer
                            ? 'Correct! Well done!'
                            : 'Incorrect. The correct answer was highlighted.',
                        style: TextStyle(
                          color: controller.isCorrectAnswer
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Show both players answered indicator
          if (bothPlayersAnswered && controller.playerIds.length >= 2)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Both players answered! Moving next!',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/splashLoading.json',
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) {
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading question...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Game Complete Header
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Trophy and Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade100, Colors.orange.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Game Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    'Category: ${controller.category.value}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Game Statistics
                _buildGameStatistics(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Results List
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.leaderboard, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      const Text(
                        'Final Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildDetailedResultsList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildGameResultActions(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatistics() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              'Questions',
              '${controller.questions.length}',
              Icons.quiz,
              Colors.blue,
            ),
            _buildStatItem(
              'Players',
              '${controller.players.length}',
              Icons.people,
              Colors.green,
            ),
            _buildStatItem(
              'Duration',
              '~${(controller.questions.length * 10 / 60).ceil()} min',
              Icons.timer,
              Colors.orange,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDetailedResultsList() {
    return Obx(() {
      return Column(
        children: controller.finalResults.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final player = result['player'];
          final score = result['score'];
          final rank = result['rank'];
          final correctAnswers = result['correctAnswers'] ?? 0;
          final totalQuestions = result['totalQuestions'] ?? 0;
          final accuracy = result['accuracy'] ?? 0;

          final isWinner = rank == 1;
          final isCurrentUser =
              player.uid ==
              controller.players
                  .firstWhereOrNull((p) => p.uid == controller.currentUser?.uid)
                  ?.uid;

          return Container(
            margin: EdgeInsets.only(
              bottom: index < controller.finalResults.length - 1 ? 16 : 0,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWinner
                    ? [Colors.amber.shade50, Colors.orange.shade50]
                    : isCurrentUser
                    ? [Colors.blue.shade50, Colors.cyan.shade50]
                    : [Colors.grey.shade50, Colors.grey.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isWinner
                    ? Colors.amber.shade300
                    : isCurrentUser
                    ? Colors.blue.shade300
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Player Header
                Row(
                  children: [
                    // Rank Badge
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isWinner
                              ? [Colors.amber, Colors.orange]
                              : [Colors.grey.shade400, Colors.grey.shade600],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isWinner
                            ? const Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 24,
                              )
                            : Text(
                                '#$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Player Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrentUser
                              ? Colors.blue.shade300
                              : Colors.grey.shade300,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: player.avatarUrl.isNotEmpty
                            ? NetworkImage(player.avatarUrl)
                            : null,
                        child: player.avatarUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                color: Colors.blue.shade600,
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Player Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                player.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$score pts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: isWinner
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Performance Metrics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetric(
                        'Correct',
                        '$correctAnswers/$totalQuestions',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildMetric(
                        'Accuracy',
                        '$accuracy%',
                        Icons.track_changes,
                        accuracy >= 70
                            ? Colors.green
                            : accuracy >= 50
                            ? Colors.orange
                            : Colors.red,
                      ),
                      _buildMetric('Score', '$score', Icons.star, Colors.amber),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildGameResultActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.playAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'Play Again',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.exitGame,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.home, size: 20),
                label: const Text(
                  'Exit Game',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Thanks for playing! 🎮',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
