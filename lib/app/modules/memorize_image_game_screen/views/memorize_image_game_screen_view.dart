import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/memorize_image_game_screen_controller.dart';

class MemorizeImageGameScreenView
    extends GetView<MemorizeImageGameScreenController> {
  const MemorizeImageGameScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen Lottie background
          Positioned.fill(
            child: Container(
              child: Lottie.asset(
                'assets/gameBackground.json',
                fit: BoxFit.fill,
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

            // Show image display phase or question phase
            if (controller.isImageDisplayPhase.value) {
              return _buildImageDisplayPhase();
            } else {
              return _buildQuestionPhase();
            }
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
              Obx(() {
                // Show different timer based on current phase
                if (controller.isImageDisplayPhase.value) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Memorize',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        Text(
                          '${controller.imageDisplayTimeLeft.value}s',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '${controller.questionPhaseTimeLeft.value}s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: controller.questionPhaseTimeLeft.value <= 3
                            ? Colors.red.shade600
                            : Colors.blue.shade700,
                      ),
                    ),
                  );
                }
              }),
              _buildPlayerInfo(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplayPhase() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Phase indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Memorize this image!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Image display
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Obx(() {
                  final question = controller.currentQuestion.value;
                  if (question != null && question['image'] != null) {
                    return Image.network(
                      question['image'],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.orange.shade600,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange.shade600,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Countdown display
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '${controller.imageDisplayTimeLeft.value}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuestionPhase() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Question text
          Container(
            width: double.infinity,
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
            child: Obx(() {
              final question = controller.currentQuestion.value;
              return Column(
                children: [
                  Text(
                    'Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question?['question'] ??
                        question?['text'] ??
                        'Loading question...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 20),

          // Answer options
          Expanded(
            child: Obx(() {
              final question = controller.currentQuestion.value;
              if (question == null || question['options'] == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final options = List<String>.from(question['options']);
              return ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildAnswerOption(index, options[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index, String option) {
    return Obx(() {
      final isSelected = controller.selectedAnswer.value == index;
      final isSubmitted = controller.isAnswerSubmitted.value;
      final correctIndex =
          controller.currentQuestion.value?['correctIndex'] ?? -1;
      final isCorrect = index == correctIndex;

      Color backgroundColor;
      Color textColor;
      Color borderColor;

      if (isSubmitted) {
        if (isCorrect) {
          backgroundColor = Colors.green.shade100;
          textColor = Colors.green.shade800;
          borderColor = Colors.green.shade300;
        } else if (isSelected && !isCorrect) {
          backgroundColor = Colors.red.shade100;
          textColor = Colors.red.shade800;
          borderColor = Colors.red.shade300;
        } else {
          backgroundColor = Colors.grey.shade100;
          textColor = Colors.grey.shade600;
          borderColor = Colors.grey.shade300;
        }
      } else {
        if (isSelected) {
          backgroundColor = Colors.blue.shade100;
          textColor = Colors.blue.shade800;
          borderColor = Colors.blue.shade300;
        } else {
          backgroundColor = Colors.white;
          textColor = Colors.black87;
          borderColor = Colors.grey.shade300;
        }
      }

      return GestureDetector(
        onTap: isSubmitted ? null : () => controller.submitAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              if (!isSubmitted)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSubmitted && isCorrect
                      ? Colors.green.shade600
                      : isSubmitted && isSelected && !isCorrect
                      ? Colors.red.shade600
                      : isSelected
                      ? Colors.blue.shade600
                      : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
              if (isSubmitted && isCorrect)
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              if (isSubmitted && isSelected && !isCorrect)
                Icon(Icons.cancel, color: Colors.red.shade600, size: 24),
            ],
          ),
        ),
      );
    });
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
          CircleAvatar(radius: 25, backgroundColor: Colors.grey.shade300),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final currentIndex = controller.currentQuestionIndex.value;
      final totalQuestions = controller.questions.length;
      final progress = totalQuestions > 0
          ? (currentIndex + 1) / totalQuestions
          : 0.0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '${currentIndex + 1}/$totalQuestions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Loading game...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: Colors.amber.shade600,
                ),
                const SizedBox(height: 20),
                Text(
                  'Game Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 30),
                Obx(() {
                  final results = controller.finalResults;
                  return Column(
                    children: results.map((result) {
                      final player = result['player'] as UserModel;
                      final score = result['score'] as int;
                      final isWinner = results.indexOf(result) == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isWinner
                              ? Colors.amber.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isWinner
                                ? Colors.amber.shade300
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (isWinner)
                              Icon(
                                Icons.star,
                                color: Colors.amber.shade600,
                                size: 30,
                              ),
                            if (isWinner) const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blue.shade100,
                              backgroundImage: player.avatarUrl.isNotEmpty
                                  ? NetworkImage(player.avatarUrl)
                                  : null,
                              child: player.avatarUrl.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: Colors.blue.shade600,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                player.username,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isWinner
                                      ? Colors.amber.shade800
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isWinner
                                    ? Colors.amber.shade600
                                    : Colors.grey.shade600,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$score',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Back to Lobby',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
