import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindrena/app/modules/home/controllers/home_controller.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

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

          // Main content over the background
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Back button and header
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  ColorizeAnimatedText(
                                    'Settings',
                                    textStyle: const TextStyle(
                                      fontSize: 24,
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
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Game Settings Section
                    _buildSectionCard(
                      title: 'Game Settings',
                      icon: Icons.gamepad,
                      children: [
                        _buildLanguageToggle(),
                        const Divider(height: 1),
                        _buildSoundToggle(),
                        const Divider(height: 1),
                        _buildNotificationToggle(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Support Section
                    _buildSectionCard(
                      title: 'Support',
                      icon: Icons.help,
                      children: [
                        _buildSettingsTile(
                          icon: Icons.help_outline,
                          title: 'User Guide',
                          subtitle: 'Get help and find answers',
                          onTap: () {
                            Get.toNamed('/user-guides');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.feedback,
                          title: 'Send Feedback',
                          subtitle: 'Share your thoughts with us',
                          onTap: () {
                            Get.toNamed('/user-feedback');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.star_rate,
                          title: 'Rate App',
                          subtitle: 'Rate us on the app store',
                          onTap: () {
                            Get.snackbar(
                              'Rate App',
                              'Thank you for your support!',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // About Section
                    _buildSectionCard(
                      title: 'About',
                      icon: Icons.info,
                      children: [
                        _buildSettingsTile(
                          icon: Icons.info_outline,
                          title: 'Version',
                          subtitle: '1.0.0',
                          showArrow: false,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: () {
                            Get.snackbar(
                              'Privacy',
                              'Privacy policy coming soon!',
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.description,
                          title: 'Terms of Service',
                          subtitle: 'Read our terms of service',
                          onTap: () {
                            Get.snackbar(
                              'Terms',
                              'Terms of service coming soon!',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '© ${DateTime.now().year} Mindrena. All rights reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: titleColor ?? Colors.grey.shade700, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.language, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Choose your preferred language',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'English',
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.purple),
                items: ['English', 'မြန်မာ'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    Get.snackbar('Language', 'Language changed to $newValue');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.volume_up, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sound Effects',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Enable or disable sound effects',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Obx(() {
            final homeController = Get.find<HomeController>();
            return Switch(
              value: homeController.isMusicEnabled.value,
              onChanged: (bool value) async {
                await homeController.setMusicEnabled(value);
              },
              activeColor: Colors.purple,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.notifications, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'Receive game updates and challenges',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (bool value) {
              Get.snackbar(
                'Notifications',
                value ? 'Notifications enabled' : 'Notifications disabled',
              );
            },
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}
