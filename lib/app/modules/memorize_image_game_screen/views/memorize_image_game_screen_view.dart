import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
              if (controller.isPreloadingImages.value) {
                return _buildPreloadingScreen();
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
                Obx(
                  () => Icon(
                    controller.isCurrentQuestionVideo
                        ? Icons.play_arrow
                        : Icons.visibility,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Text(
                    controller.isCurrentQuestionVideo
                        ? 'Watch this video!'
                        : 'Memorize this image!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Media display (Image or Video)
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
                  // Check if this is a video question
                  if (controller.isCurrentQuestionVideo) {
                    return _buildVideoDisplay();
                  } else {
                    return _buildImageDisplay();
                  }
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
                          // Player name - use Flexible to prevent overflow
                          Text(
                            player.username,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Points
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

  Widget _buildPreloadingScreen() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
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
                  Icons.download_for_offline,
                  size: 60,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(height: 20),
                Text(
                  'Preparing Images...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Loading images for a smooth gaming experience',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Obx(() {
                  final progress = controller.preloadingProgress.value;
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange.shade600,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Skip preloading button for poor connections
                TextButton(
                  onPressed: () {
                    controller.skipPreloading();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.skip_next,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Skip (Poor Connection?)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
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
    );
  }

  Widget _buildVideoDisplay() {
    return Obx(() {
      if (controller.isVideoLoading.value) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.orange.shade600,
                strokeWidth: 3,
              ),
              const SizedBox(height: 15),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        );
      }

      if (controller.videoLoadError.value) {
        return SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                'Failed to load video',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                'Continuing with game...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        );
      }

      if (controller.youtubeController != null) {
        return YoutubePlayer(
          controller: controller.youtubeController!,
          showVideoProgressIndicator: false,
          bottomActions: const [],
          topActions: const [],
          aspectRatio: 16 / 9,
        );
      }

      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: Colors.orange.shade600),
        ),
      );
    });
  }

  Widget _buildImageDisplay() {
    final question = controller.currentQuestion.value;
    if (question != null && question['image'] != null) {
      final imageUrl = question['image'];
      final isPreloaded = controller.preloadedImages[imageUrl] == true;

      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          // Show enhanced loading indicator
          return SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.orange.shade600,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 15),
                Text(
                  isPreloaded ? 'Loading cached image...' : 'Loading image...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                if (loadingProgress.expectedTotalBytes != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  'Continuing with game...',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
        child: CircularProgressIndicator(color: Colors.orange.shade600),
      ),
    );
  }
}
