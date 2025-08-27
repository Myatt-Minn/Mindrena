import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/sg_home_controller.dart';

class SgHomeView extends GetView<SgHomeController> {
  const SgHomeView({super.key});
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

                    // Welcome header with animated text
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
                          // Header with notification icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      'Choose Your Game',
                                      textStyle: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      colors: [
                                        Colors.purple,
                                        Colors.purple,
                                        Colors.blue,
                                        Colors.teal,
                                      ],
                                      speed: const Duration(milliseconds: 400),
                                    ),
                                  ],
                                  isRepeatingAnimation: true,
                                  repeatForever: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Test your mind with these exciting challenges!',
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

                    // Game mode buttons
                    _buildGameButton(
                      emoji: '🧠',
                      title: 'Memory War',
                      subtitle: 'Visual Recall',
                      description:
                          'Challenge your visual memory and pattern recognition',
                      color: Colors.purple,
                      onTap: () {
                        // Navigate to Memory War category selection
                        Get.toNamed('/m-category-selection');
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildGameButton(
                      emoji: '⚡',
                      title: 'FlashFight',
                      subtitle: 'Quiz Battle',
                      description:
                          'Fast-paced quiz battles against other players',
                      color: Colors.red,
                      onTap: () {
                        // Navigate to FlashFight category selection
                        Get.toNamed('/sg-f-category-selection');
                      },
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),

                    // Profile/Settings section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.person_pin_rounded,
                            label: 'Profile',
                            onTap: () {
                              Get.toNamed('/profile');
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.shopping_cart,
                            label: 'Shop',
                            onTap: () {
                              Get.snackbar(
                                'Coming Soon',
                                'Shop will be available soon!',
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.group,
                            label: 'Friends',
                            onTap: () {
                              Get.toNamed('/friends');
                            },
                          ),
                        ],
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Get.toNamed('/settings');
                      },
                      child: AutoSizeText(
                        'Manage Preferences and Get Help -> Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),

                        maxLines: 1,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton({
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

                // Game info
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.grey.shade700),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
