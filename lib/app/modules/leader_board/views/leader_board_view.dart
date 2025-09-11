import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/consts_config.dart';
import 'package:mindrena/app/utils/number_formatter.dart';

import '../controllers/leader_board_controller.dart';

class LeaderBoardView extends GetView<LeaderBoardController> {
  const LeaderBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshLeaderboard(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading leaderboard...'),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header with current user rank
            _buildHeader(),

            // Filter and search section
            _buildFilterSection(),

            // Leaderboard list
            Expanded(
              child: controller.filteredUsers.isEmpty
                  ? _buildEmptyState()
                  : _buildLeaderboardList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Obx(() {
        final currentUser = controller.currentUser.value;
        final rank = controller.currentUserRank.value;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (currentUser != null) ...[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: currentUser.avatarUrl.isNotEmpty
                      ? NetworkImage(currentUser.avatarUrl)
                      : null,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: currentUser.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser.username,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.getRankIcon(rank),
                      color: rank <= 3
                          ? controller.getRankColor(rank)
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rank > 0 ? 'Rank #$rank' : 'Unranked',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.getFilterValue(
                    currentUser,
                    controller.selectedFilter.value,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (rank > 0)
                  Text(
                    controller.getMotivationalMessage(
                      rank,
                      controller.filteredUsers.length,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ] else ...[
                const Icon(Icons.person, size: 60, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'Guest User',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: 'Search players...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ConstsConfig.primarycolor),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.filterOptions.length,
              itemBuilder: (context, index) {
                final filter = controller.filterOptions[index];
                final isSelected = controller.selectedFilter.value == filter;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < controller.filterOptions.length - 1 ? 8 : 0,
                  ),
                  child: FilterChip(
                    label: Text(
                      controller.filterLabels[filter] ?? filter,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? Colors.white
                            : ConstsConfig.primarycolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => controller.changeFilter(filter),
                    backgroundColor: Colors.white,
                    selectedColor: Color(0xFF667eea),
                    checkmarkColor: Colors.white,
                    side: BorderSide(color: ConstsConfig.primarycolor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: controller.filteredUsers.length,
        itemBuilder: (context, index) {
          final user = controller.filteredUsers[index];
          final rank = index + 1;
          final isCurrentUser = controller.isCurrentUser(user);

          return _buildLeaderboardItem(user, rank, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(UserModel user, int rank, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('friend-profile', arguments: user);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? ConstsConfig.primarycolor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentUser
              ? Border.all(color: ConstsConfig.primarycolor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? controller.getRankColor(rank)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: rank <= 3
                      ? Icon(
                          controller.getRankIcon(rank),
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '$rank',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // User avatar
              CircleAvatar(
                radius: 25,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                backgroundColor: ConstsConfig.primarycolor.withOpacity(0.7),
                child: user.avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.username,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser
                                  ? ConstsConfig.primarycolor
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ConstsConfig.primarycolor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'You',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.games,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ' ${user.gamesWon.formatCompact()} wins',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Win Rate: ${user.winRate.formatPercentage()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Score value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    controller.getFilterValue(
                      user,
                      controller.selectedFilter.value,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: controller.getScoreColor(
                        controller.selectedFilter.value,
                        user,
                      ),
                    ),
                  ),
                  Text(
                    controller.filterLabels[controller.selectedFilter.value] ??
                        '',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No players found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.value.isNotEmpty
                ? 'Try adjusting your search'
                : 'Start playing games to appear on the leaderboard!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.refreshLeaderboard(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstsConfig.primarycolor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Refresh',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
