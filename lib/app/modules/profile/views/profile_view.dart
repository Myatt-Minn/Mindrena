import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindrena/app/modules/auth_gate/controllers/auth_gate_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

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
                child: Obx(
                  () => controller.isLoading.value
                      ? _buildShimmerContent()
                      : _buildMainContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700, size: 24),
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
                        color: Colors.grey.shade800,
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

  // Build shimmer loading content
  Widget _buildShimmerContent() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Back button and header shimmer
        Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Profile card shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile picture shimmer
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name shimmer
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email shimmer
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Button shimmer
                  Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Statistics section shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Account actions shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // Build main content when not loading
  Widget _buildMainContent() {
    return Column(
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
                icon: const Icon(Icons.arrow_back_ios, color: Colors.purple),
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
                        'Profile',
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

        // Profile Info Card
        Container(
          width: double.infinity,
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        (controller.user.value != null &&
                            controller.user.value!.avatarUrl.isNotEmpty)
                        ? Image.network(
                            controller.user.value!.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.purple.shade400,
                              );
                            },
                          )
                        : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.purple.shade400,
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // User Name
                Text(
                  controller.user.value?.username ?? 'Player Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 4),

                // Email
                Text(
                  controller.user.value?.email ?? 'player@example.com',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 20),

                // Edit Profile Button
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/edit-profile');
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: Text('edit_profile'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Statistics Section
        Container(
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.purple, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'game_statistics'.tr,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.games,
                        title: 'Games Played',
                        value: '${controller.user.value?.gamesPlayed ?? 0}',
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        title: 'Wins',
                        value: '${controller.user.value?.gamesWon ?? 0}',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.percent,
                        title: 'Win Rate',
                        value:
                            '${controller.user.value?.winRate.toStringAsFixed(1) ?? 0.0}%',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.star,
                        title: 'Total Points',
                        value: '${controller.user.value?.totalPoints ?? 0}',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildStatCard(
                          icon: Icons.monetization_on,
                          title: 'Total Coins',
                          value: '${controller.userCoins.value}',
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '50 coins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'per 100 points',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Purchased Items Tab Section
        Container(
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
            children: [
              // Tab Headers
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 0
                                  ? Colors.purple.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: controller.selectedTab.value == 0
                                      ? Colors.purple
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.face,
                                  color: controller.selectedTab.value == 0
                                      ? Colors.purple
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Avatars',
                                  style: TextStyle(
                                    color: controller.selectedTab.value == 0
                                        ? Colors.purple
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 1
                                  ? Colors.purple.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: controller.selectedTab.value == 1
                                      ? Colors.purple
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: controller.selectedTab.value == 1
                                      ? Colors.purple
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Stickers',
                                  style: TextStyle(
                                    color: controller.selectedTab.value == 1
                                        ? Colors.purple
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.changeTab(2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: controller.selectedTab.value == 2
                                  ? Colors.purple.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: controller.selectedTab.value == 2
                                      ? Colors.purple
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: controller.selectedTab.value == 2
                                      ? Colors.purple
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Trophies',
                                  style: TextStyle(
                                    color: controller.selectedTab.value == 2
                                        ? Colors.purple
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Content
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Account Actions
        Container(
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
            children: [
              _buildActionTile(
                icon: Icons.shop,
                title: 'shop'.tr,
                subtitle: 'Browse and purchase items',
                onTap: () => Get.toNamed('/shop'),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.settings,
                title: 'settings'.tr,
                subtitle: 'Manage your preferences',
                onTap: () => Get.toNamed('/settings'),
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.videogame_asset,
                title: 'switch_player_mode'.tr,
                subtitle: 'Go back to Player Mode Selection',
                onTap: () {
                  Get.delete<AuthGateController>(force: true);
                  Get.offAllNamed('/player-mode-selection');
                },
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.logout,
                title: 'logout'.tr,
                subtitle: 'Sign out of your account',
                onTap: () {
                  Get.defaultDialog(
                    title: 'logout'.tr,
                    middleText: 'Are you sure you want to sign out?',
                    textConfirm: 'Sign Out',
                    textCancel: 'Cancel',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      controller.signOut();
                      Get.back();
                    },
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildAvatarsTab();
      case 1:
        return _buildStickersTab();
      case 2:
        return _buildTrophiesTab();
      default:
        return _buildAvatarsTab();
    }
  }

  Widget _buildAvatarsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchased Avatars',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.purchasedAvatars.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.face_retouching_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No avatars purchased yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit the shop to buy cool avatars!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: controller.purchasedAvatars.length,
            itemBuilder: (context, index) {
              final avatar = controller.purchasedAvatars[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purple, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          avatar['url']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: Colors.purple,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      avatar['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildStickersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchased Stickers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.purchasedStickers.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No stickers purchased yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visit the shop to buy expressive stickers!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: controller.purchasedStickers.length,
            itemBuilder: (context, index) {
              final sticker = controller.purchasedStickers[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      sticker['url']!,
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.emoji_emotions,
                          color: Colors.orange,
                          size: 40,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sticker['name']!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildTrophiesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earned Trophies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.trophies.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trophies earned yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep playing to unlock achievements!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.trophies.length,
            itemBuilder: (context, index) {
              final trophy = controller.trophies[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 2),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trophy['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            trophy['description']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
