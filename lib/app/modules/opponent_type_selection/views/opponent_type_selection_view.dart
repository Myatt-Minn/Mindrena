import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/opponent_type_selection_controller.dart';

class OpponentTypeSelectionView
    extends GetView<OpponentTypeSelectionController> {
  const OpponentTypeSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the category from arguments
    final String category = Get.arguments ?? 'General Knowledge';

    return Scaffold(
      body: Stack(
        children: [
          // Full screen Lottie background
          Positioned.fill(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Lottie.asset(
                'assets/gameBackground.json',
                fit: BoxFit.fill,
                repeat: true,
                width: double.infinity,
                height: double.infinity,
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
                                'Choose Opponent',
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
                            'Select how you want to play $category',
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

                    // Opponent type selection buttons
                    _buildOpponentTypeButton(
                      emoji: 'assets/gaming.gif',
                      title: 'Online Random Opponent',
                      subtitle: 'Quick Match',
                      description:
                          'Find a random player online for instant gameplay',
                      color: Colors.green,
                      onTap: () {
                        // Navigate to lobby with random matchmaking
                        Get.toNamed(
                          '/lobby',
                          arguments: {
                            'category': category,
                            'gameMode': 'random',
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildOpponentTypeButton(
                      emoji: 'assets/friends.gif',
                      title: 'Invite Friend',
                      subtitle: 'Play with Friends',
                      description: 'Send game invitations to your friends',
                      color: Colors.deepPurple,
                      onTap: () async {
                        // Use HomeController to show invite friends dialog
                        try {
                          controller.inviteFriend(category);
                        } catch (e) {
                          // If HomeController is not found, show error
                          Get.snackbar(
                            'Error',
                            'Unable to access friends list. Please try again.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Game Rules',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.timer, '10 seconds per question'),
                          _buildInfoRow(
                            Icons.star,
                            'Points = remaining seconds (1-10)',
                          ),
                          _buildInfoRow(
                            Icons.emoji_events,
                            'Best of 10 questions wins',
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

  Widget _buildOpponentTypeButton({
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
                    child: Image.asset(
                      emoji,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback icon based on the game type
                        IconData fallbackIcon = Icons.games;
                        if (emoji.contains('gaming')) {
                          fallbackIcon = Icons.headphones;
                        } else if (emoji.contains('friends')) {
                          fallbackIcon = Icons.psychology;
                        }
                        return Icon(fallbackIcon, color: color, size: 30);
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Obx(() {
                  return controller.isLoading.value
                      ? Expanded(
                          child: Center(
                            child: Shimmer(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade100,
                                ],
                                stops: const [0.4, 0.6],
                                begin: Alignment(-1, 0),
                                end: Alignment(1, 0),
                              ),
                              child: Container(
                                height: 20,
                                width: 100,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
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
                        );
                }), // Opponent type info
                // Arrow icon
                Icon(Icons.arrow_forward_ios, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
