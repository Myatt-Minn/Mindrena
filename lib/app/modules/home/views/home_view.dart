import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    bool shouldExit = false;
    return WillPopScope(
      onWillPop: () async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.redAccent, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirm Exit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 8),
                  Text(
                    'Are you sure you want to exit the game?',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('No'),
                  onPressed: () {
                    shouldExit = false;
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Yes'),
                  onPressed: () {
                    shouldExit = true;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return shouldExit;
      },
      child: Scaffold(
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

            // Main content over the background
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Welcome header with animated text
                      Container(
                        padding: const EdgeInsets.all(12),
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
                                  child: Center(
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        ColorizeAnimatedText(
                                          'choose_your_game'.tr,
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
                                          speed: const Duration(
                                            milliseconds: 400,
                                          ),
                                        ),
                                      ],
                                      isRepeatingAnimation: true,
                                      repeatForever: true,
                                    ),
                                  ),
                                ),
                                // Invitation notification badge
                                Obx(
                                  () => controller.hasPendingInvitations
                                      ? Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Stack(
                                              children: [
                                                Icon(
                                                  Icons.mail,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                                if (controller
                                                        .pendingInvitationsCount >
                                                    0)
                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            2,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                Colors.yellow,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: Text(
                                                        '${controller.pendingInvitationsCount}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            onPressed: () {
                                              // Show pending invitations
                                              _showPendingInvitations();
                                            },
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Game mode buttons
                      _buildGameButton(
                        emoji: 'assets/headphones.gif',
                        title: 'SoundIt',
                        subtitle: 'Audio Challenge',
                        description:
                            'Test your audio memory and recognition skills',
                        color: Colors.orange,
                        onTap: () {
                          // Navigate to SoundIt category selection
                          Get.toNamed('/s-category-selection');
                        },
                      ),

                      const SizedBox(height: 20),

                      _buildGameButton(
                        emoji: 'assets/memory.gif',
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
                        emoji: 'assets/thunder.gif',
                        title: 'FlashFight',
                        subtitle: 'Quiz Battle',
                        description:
                            'Fast-paced quiz battles against other players',
                        color: Colors.red,
                        onTap: () {
                          // Navigate to FlashFight category selection
                          Get.toNamed('/f-category-selection');
                        },
                      ),

                      const SizedBox(height: 20),
                      _buildGameButton(
                        emoji: 'assets/photograph.gif',
                        title: 'GuessPic',
                        subtitle: 'Image Guessing',
                        description:
                            'Guess the image based on the clues provided',
                        color: Colors.deepPurpleAccent,
                        onTap: () {
                          // Navigate to Guess category selection
                          Get.toNamed('/g-category-selection');
                        },
                      ),

                      const SizedBox(height: 24),

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
                              icon: 'assets/profile.png',
                              label: 'profile'.tr,
                              onTap: () {
                                Get.toNamed('/profile');
                              },
                            ),
                            _buildActionButton(
                              icon: 'assets/shop.png',
                              label: 'shop'.tr,
                              onTap: () {
                                Get.toNamed('/shop');
                              },
                            ),
                            _buildActionButton(
                              icon: 'assets/friends.png',
                              label: 'friends'.tr,
                              onTap: () {
                                Get.toNamed('/friends');
                              },
                            ),
                            _buildActionButton(
                              icon: 'assets/leaderboard.png',
                              label: 'Ranking'.tr,
                              onTap: () {
                                Get.toNamed('/leader-board');
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

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
            padding: const EdgeInsets.all(16),
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
                        if (emoji.contains('headphones')) {
                          fallbackIcon = Icons.headphones;
                        } else if (emoji.contains('brain')) {
                          fallbackIcon = Icons.psychology;
                        } else if (emoji.contains('thunder')) {
                          fallbackIcon = Icons.flash_on;
                        }
                        return Icon(fallbackIcon, color: color, size: 30);
                      },
                    ),
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
    required String icon,
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
            Image.asset(
              icon,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icons based on the label
                IconData fallbackIcon = Icons.help;
                if (label == 'Profile') {
                  fallbackIcon = Icons.person;
                } else if (label == 'Shop') {
                  fallbackIcon = Icons.shopping_cart;
                } else if (label == 'Friends') {
                  fallbackIcon = Icons.people;
                }
                return Icon(
                  fallbackIcon,
                  size: 24,
                  color: Colors.grey.shade600,
                );
              },
            ),
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

  void _showPendingInvitations() {
    if (controller.pendingInvitations.isEmpty) {
      Get.snackbar(
        'No Invitations',
        'You don\'t have any pending game invitations.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.mail, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('Game Invitations'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: controller.pendingInvitations.length,
            itemBuilder: (context, index) {
              final invitation = controller.pendingInvitations[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        invitation['inviterAvatarUrl'] != null &&
                            invitation['inviterAvatarUrl'].isNotEmpty
                        ? NetworkImage(invitation['inviterAvatarUrl'])
                        : null,
                    child:
                        invitation['inviterAvatarUrl'] == null ||
                            invitation['inviterAvatarUrl'].isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text('${invitation['inviterUsername']}'),
                  subtitle: Text('Category: ${invitation['category']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          // Decline invitation
                          controller.declineInvitation(invitation['id']);
                          controller.pendingInvitations.removeAt(index);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          // Accept invitation
                          controller.acceptInvitation(
                            invitation,
                            invitation['id'],
                          );
                          controller.pendingInvitations.removeAt(index);
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Close')),
        ],
      ),
    );
  }
}
