import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/sg_f_difficulty_selection_controller.dart';

class SgFDifficultySelectionView
    extends GetView<SgFDifficultySelectionController> {
  const SgFDifficultySelectionView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
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

          // Main content over the background
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Back button
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.purple,
                            ),
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Header with animated text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
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
                          AnimatedTextKit(
                            animatedTexts: [
                              ColorizeAnimatedText(
                                'Choose Difficulty',
                                textStyle: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                colors: [
                                  Colors.purple,
                                  Colors.blue,
                                  Colors.purple,
                                  Colors.teal,
                                ],
                                speed: const Duration(milliseconds: 400),
                              ),
                            ],
                            isRepeatingAnimation: true,
                            repeatForever: true,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select a difficulty level:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Category selection buttons
                    _buildCategoryButton(
                      emoji: '😊',
                      title: 'Easy',
                      subtitle: 'A Gentle Start',
                      description:
                          'A relaxed pace with straightforward questions. Perfect for a warm-up!', // CHANGE: Explains what "Easy" means
                      color: Colors.green,
                      onTap: () {
                        Get.toNamed(
                          '/sg-quiz',
                          arguments: {
                            'category': controller.selectedCategory.value,
                            'difficulty': 'Easy',
                            'type': controller.selectedType.value,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- MEDIUM ---
                    _buildCategoryButton(
                      emoji: '🤔',
                      title: 'Medium',
                      subtitle: 'A Balanced Challenge',
                      description:
                          'Put your knowledge to the test with a balanced set of challenging questions.', // CHANGE: Sets expectations
                      color: Colors.orange,
                      onTap: () {
                        Get.toNamed(
                          '/sg-quiz',
                          arguments: {
                            'category': controller.selectedCategory.value,
                            'difficulty': 'Medium',
                            'type': controller.selectedType.value,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildCategoryButton(
                      emoji: '🔥',
                      title: 'Hard',
                      subtitle: 'The Ultimate Test',
                      description:
                          'Do you have what it takes? These questions will push your knowledge to the limit.', // CHANGE: A direct challenge to the user
                      color: Colors.deepPurple,
                      onTap: () {
                        Get.toNamed(
                          '/sg-quiz',
                          arguments: {
                            'category': controller.selectedCategory.value,
                            'difficulty': 'Hard',
                            'type': controller.selectedType.value,
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Additional info section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.quiz,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fast-paced quiz battles await you!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({
    required String emoji,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Emoji container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: color.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),

                const SizedBox(width: 16),

                // Category info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(Icons.arrow_forward_ios, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
