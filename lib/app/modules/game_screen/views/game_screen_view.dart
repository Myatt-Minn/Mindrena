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
        const SizedBox(height: 20),
        _buildProgressBar(),
        const SizedBox(height: 20),
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
      margin: const EdgeInsets.all(16),
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
          const SizedBox(height: 20),
          Expanded(child: _buildAnswerOptions()),
          if (controller.isAnswerSubmitted.value) _buildAnswerFeedback(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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

        return Text(
          question['text'] ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        );
      }),
    );
  }

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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  'Game Finished!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                _buildResultsList(),
                const SizedBox(height: 30),
                _buildGameResultActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Obx(() {
      return Column(
        children: controller.finalResults.map((result) {
          final player = result['player'];
          final score = result['score'];
          final rank = result['rank'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rank == 1 ? Colors.amber.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rank == 1 ? Colors.amber.shade300 : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rank == 1 ? Colors.amber : Colors.grey.shade400,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: player.avatarUrl.isNotEmpty
                      ? NetworkImage(player.avatarUrl)
                      : null,
                  child: player.avatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.blue.shade600)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    player.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '$score pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: rank == 1
                        ? Colors.amber.shade700
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildGameResultActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: controller.playAgain,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Play Again',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: controller.exitGame,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Exit Game',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
