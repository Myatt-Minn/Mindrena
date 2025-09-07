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
                                    'settings'.tr,
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
                      title: 'game_settings'.tr,
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
                      title: 'support'.tr,
                      icon: Icons.help,
                      children: [
                        _buildSettingsTile(
                          icon: Icons.help_outline,
                          title: 'user_guide'.tr,
                          subtitle: 'get_help'.tr,
                          onTap: () {
                            Get.toNamed('/user-guides');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.feedback,
                          title: 'send_feedback'.tr,
                          subtitle: 'share_your_thoughts'.tr,
                          onTap: () {
                            Get.toNamed('/user-feedback');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.star_rate,
                          title: 'rate_app'.tr,
                          subtitle: 'rate_us_on_store'.tr,
                          onTap: () {
                            Get.snackbar(
                              'rate_app'.tr,
                              'thank_you_for_support'.tr,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // About Section
                    _buildSectionCard(
                      title: 'about'.tr,
                      icon: Icons.info,
                      children: [
                        _buildSettingsTile(
                          icon: Icons.info_outline,
                          title: 'version'.tr,
                          subtitle: '1.0.0',
                          showArrow: false,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.privacy_tip,
                          title: 'privacy_policy'.tr,
                          subtitle: 'read_privacy_policy'.tr,
                          onTap: () {
                            Get.snackbar(
                              'privacy_policy'.tr,
                              'privacy_policy_soon'.tr,
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.description,
                          title: 'terms_of_service'.tr,
                          subtitle: 'read_terms_of_service'.tr,
                          onTap: () {
                            Get.snackbar(
                              'terms_of_service'.tr,
                              'terms_of_service_soon'.tr,
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSectionCard(
                      title: 'account_settings'.tr,
                      icon: Icons.account_circle,
                      children: [
                        _buildSettingsTile(
                          icon: Icons.switch_account,
                          title: 'switch_player_mode'.tr,
                          subtitle: 'Go back to player mode screen',
                          showArrow: false,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.logout,
                          title: 'logout'.tr,
                          subtitle: 'Log out of your account'.tr,
                          onTap: () {
                            Get.offAllNamed('/login');
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
                        'all_rights_reserved'.trParams({
                          'year': DateTime.now().year.toString(),
                        }),
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
                  'language'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'choose_language'.tr,
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
                value: Get.locale?.languageCode == 'my' ? 'my' : 'en',
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.purple),
                items:
                    [
                      {'code': 'en', 'name': 'english'.tr},
                      {'code': 'my', 'name': 'myanmar'.tr},
                    ].map((Map<String, String> lang) {
                      final value = lang['name']!;
                      return DropdownMenuItem<String>(
                        value: lang['code']!,
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
                    final locale = newValue == 'en'
                        ? const Locale('en', 'US')
                        : const Locale('my', 'MM');
                    Get.updateLocale(locale);
                    Get.snackbar(
                      'language'.tr,
                      'Language changed to ${newValue == 'en' ? 'english'.tr : 'myanmar'.tr}',
                    );
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
                  'sound_effects'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'enable_disable_sound'.tr,
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
                  'notifications'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'receive_updates'.tr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (bool value) {
              Get.snackbar(
                'notifications'.tr,
                value
                    ? 'notifications_enabled'.tr
                    : 'notifications_disabled'.tr,
              );
            },
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
}
