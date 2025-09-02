import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

import '../controllers/sg_quiz_controller.dart';

class SgQuizView extends GetView<SgQuizController> {
  const SgQuizView({super.key});
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
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              return _buildGameContent(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 20),
        _buildProgressBar(),
        const SizedBox(height: 20),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildLoadingState();
            }
            return _buildQuestionSection();
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: controller.changeColor.value
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.changeColor.value
                        ? Colors.red.shade200
                        : Colors.blue.shade200,
                  ),
                ),
                child: Obx(
                  () => Container(
                    key: ValueKey(controller.timerEndTime.value),
                    child: TimerCountdown(
                      timeTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      onTick: (remainingTime) => {
                        if (remainingTime.inSeconds <= 3)
                          {
                            controller.changeColor.value = true,
                            HapticFeedback.mediumImpact(),
                          },
                      },
                      enableDescriptions: false,
                      format: CountDownTimerFormat.secondsOnly,
                      endTime: controller.timerEndTime.value,
                      onEnd: () {
                        Future.microtask(() {
                          controller.chooseAnswer('');
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Obx(
                  () => Text(
                    'score'.trParams({
                      'score': '${controller.score.value * 10}',
                    }),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
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
                  'question_of'.trParams({
                    'current': '${controller.currentQuestionIndex.value + 1}',
                    'total': '${controller.questions.length}',
                  }),
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

        return Text(
          question,
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
      final options = controller.answers;

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
      final String? chosenAnswer = controller.selectedAnswer.value;
      final isAnswerSubmitted = chosenAnswer != null;

      final bool isSelected = chosenAnswer == option;
      final bool isCorrect =
          option ==
          controller
              .questions[controller.currentQuestionIndex.value]
              .correctAnswer;

      final colors = _getAnswerColors(
        isSelected: isSelected,
        isCorrect: isCorrect,
        isAnswerSubmitted: isAnswerSubmitted,
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isAnswerSubmitted
                ? null
                : () => controller.chooseAnswer(option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _AnswerStateIndicator(
                    index: index,
                    isSelected: isSelected,
                    isCorrect: isCorrect,
                    isAnswerSubmitted: isAnswerSubmitted,
                    borderColor: colors.border,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: colors.text,
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

  ({Color background, Color border, Color text}) _getAnswerColors({
    required bool isSelected,
    required bool isCorrect,
    required bool isAnswerSubmitted,
  }) {
    if (isAnswerSubmitted) {
      if (isCorrect) {
        return (
          background: Colors.green.shade50,
          border: Colors.green.shade300,
          text: Colors.green.shade700,
        );
      } else if (isSelected) {
        return (
          background: Colors.red.shade50,
          border: Colors.red.shade300,
          text: Colors.red.shade700,
        );
      } else {
        return (
          background: Colors.grey.shade50,
          border: Colors.grey.shade300,
          text: Colors.grey.shade600,
        );
      }
    } else {
      return (
        background: Colors.white.withOpacity(0.95),
        border: Colors.grey.shade300,
        text: Colors.black87,
      );
    }
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
          Text(
            'loading_question'.tr,
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          Text(
            'quiz_results_summary'.trParams({
              'score': '${controller.score.value}',
              'total': '${controller.questions.length}',
            }),
            style: TextStyle(
              color: const Color.fromARGB(200, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.summary.length,
                itemBuilder: (context, index) {
                  final data = controller.summary[index];
                  return _SummaryItem(
                    index: data['question_index'] as int,
                    question: data['question'] as String,
                    userAnswer: data['user_answer'] as String,
                    correctAnswer: data['correct_answer'] as String,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildGameResultActions(),
        ],
      ),
    );
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
            child: Text(
              'play_again'.tr,
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
            child: Text(
              'exit_game'.tr,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.index,
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
  });

  final int index;
  final String question;
  final String userAnswer;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final isCorrect = userAnswer == correctAnswer;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect ? Colors.green.shade400 : Colors.red.shade400,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'your_answer'.trParams({'answer': userAnswer}),
                  style: TextStyle(
                    color: isCorrect
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 4),
                  Text(
                    'correct_answer'.trParams({'answer': correctAnswer}),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerStateIndicator extends StatelessWidget {
  const _AnswerStateIndicator({
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswerSubmitted,
    required this.borderColor,
  });

  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswerSubmitted;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    IconData? iconData;
    if (isAnswerSubmitted) {
      // If this option is the correct one, show a check mark.
      if (isCorrect) {
        iconData = Icons.check;
      }
      // If this option was selected but is incorrect, show a close mark.
      else if (isSelected) {
        iconData = Icons.close;
      }
    }

    final bool hasIcon = iconData != null;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasIcon ? borderColor : Colors.transparent,
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: hasIcon
            ? Icon(iconData, color: Colors.white, size: 16)
            : Text(
                String.fromCharCode('A'.codeUnitAt(0) + index),
                style: TextStyle(
                  color: borderColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}
