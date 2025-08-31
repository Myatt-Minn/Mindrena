import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/consts_config.dart';

import '../controllers/friends_controller.dart';

class FriendsView extends GetView<FriendsController> {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with back button and title
                Container(
                  margin: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: ConstsConfig.primarycolor,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedTextKit(
                            animatedTexts: [
                              ColorizeAnimatedText(
                                'Friends',
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                colors: [
                                  ConstsConfig.primarycolor,
                                  ConstsConfig.primaryColorLight,
                                  ConstsConfig.secondarycolor,
                                  Colors.purple,
                                ],
                                speed: const Duration(milliseconds: 400),
                              ),
                            ],
                            repeatForever: true,
                            pause: const Duration(milliseconds: 1000),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // To balance the back button
                    ],
                  ),
                ),

                // Tab bar with theme styling
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ConstsConfig.primarycolor,
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.white,
                              unselectedLabelColor: ConstsConfig.primarycolor,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              tabs: const [
                                Tab(
                                  text: 'Friends',
                                  icon: Icon(Icons.people, size: 18),
                                ),
                                Tab(
                                  text: 'Requests',
                                  icon: Icon(Icons.person_add, size: 18),
                                ),
                                Tab(
                                  text: 'Find',
                                  icon: Icon(Icons.search, size: 18),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildFriendsTab(),
                                _buildRequestsTab(),
                                _buildSearchTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Add bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: ConstsConfig.primarycolor),
        );
      }

      if (controller.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: ConstsConfig.primarycolor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No friends yet',
                style: TextStyle(
                  fontSize: 18,
                  color: ConstsConfig.primarycolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use the Find tab to search for friends',
                style: TextStyle(
                  fontSize: 14,
                  color: ConstsConfig.primarycolor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.friends.length,
          itemBuilder: (context, index) {
            final friend = controller.friends[index];
            return _buildFriendCard(friend);
          },
        ),
      );
    });
  }

  Widget _buildRequestsTab() {
    return Obx(() {
      if (controller.friendRequests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: ConstsConfig.primarycolor.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No friend requests',
                style: TextStyle(
                  fontSize: 18,
                  color: ConstsConfig.primarycolor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Friend requests will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: ConstsConfig.primarycolor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.friendRequests.length,
        itemBuilder: (context, index) {
          final request = controller.friendRequests[index];
          return _buildRequestCard(request);
        },
      );
    });
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                hintStyle: TextStyle(
                  color: ConstsConfig.primarycolor.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ConstsConfig.primarycolor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: ConstsConfig.primarycolor),
              onChanged: (value) {
                controller.searchUsers(value);
              },
            ),
          ),
          Flexible(
            child: Obx(() {
              if (controller.isSearching.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: ConstsConfig.primarycolor,
                  ),
                );
              }

              if (controller.searchController.text.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 80,
                        color: ConstsConfig.primarycolor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for friends',
                        style: TextStyle(
                          fontSize: 18,
                          color: ConstsConfig.primarycolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter a username to find friends',
                        style: TextStyle(
                          fontSize: 14,
                          color: ConstsConfig.primarycolor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 80,
                        color: ConstsConfig.primarycolor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 18,
                          color: ConstsConfig.primarycolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different username',
                        style: TextStyle(
                          fontSize: 14,
                          color: ConstsConfig.primarycolor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final user = controller.searchResults[index];
                  return _buildSearchResultCard(user, context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(UserModel friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ConstsConfig.primarycolor, width: 2),
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: ConstsConfig.primarycolor.withOpacity(0.1),
            backgroundImage: friend.avatarUrl.isNotEmpty
                ? NetworkImage(friend.avatarUrl)
                : null,
            child: friend.avatarUrl.isEmpty
                ? Text(
                    friend.username.isNotEmpty
                        ? friend.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstsConfig.primarycolor,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          friend.username,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ConstsConfig.primarycolor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ConstsConfig.secondarycolor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Games Won: ${friend.gamesWon}   Points: ${friend.totalPoints}',
                style: TextStyle(
                  fontSize: 12,
                  color: ConstsConfig.primarycolor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: ConstsConfig.primarycolor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: ConstsConfig.primarycolor),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Colors.red.shade400),
                    const SizedBox(width: 8),
                    const Text('Remove Friend'),
                  ],
                ),
                onTap: () => _showRemoveFriendDialog(friend),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(UserModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ConstsConfig.secondarycolor, width: 2),
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: ConstsConfig.secondarycolor.withOpacity(0.1),
            backgroundImage: request.avatarUrl.isNotEmpty
                ? NetworkImage(request.avatarUrl)
                : null,
            child: request.avatarUrl.isEmpty
                ? Text(
                    request.username.isNotEmpty
                        ? request.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstsConfig.secondarycolor,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          request.username,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ConstsConfig.primarycolor,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'wants to be your friend',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.orange,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => controller.acceptFriendRequest(request),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.red.shade400),
                onPressed: () => controller.declineFriendRequest(request),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(UserModel user, BuildContext context) {
    final status = controller.getRelationshipStatus(user);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ConstsConfig.primaryColorLight, width: 2),
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: ConstsConfig.primaryColorLight.withOpacity(0.1),
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? Text(
                    user.username.isNotEmpty
                        ? user.username[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstsConfig.primaryColorLight,
                    ),
                  )
                : null,
          ),
        ),
        title: Text(
          user.username,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: ConstsConfig.primarycolor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ConstsConfig.secondarycolor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Games Won: ${user.gamesWon}   Points: ${user.totalPoints}',
                style: TextStyle(
                  fontSize: 12,
                  color: ConstsConfig.primarycolor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: _buildActionButton(user, status, context),
      ),
    );
  }

  Widget _buildActionButton(
    UserModel user,
    String status,
    BuildContext context,
  ) {
    switch (status) {
      case 'friend':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Friend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'pending_sent':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.orange.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Sent',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'pending_received':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            'Pending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      default:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ConstsConfig.primarycolor,
                ConstsConfig.primaryColorLight,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ConstsConfig.primarycolor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => controller.sendFriendRequest(user, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        );
    }
  }

  void _showRemoveFriendDialog(UserModel friend) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove ${friend.username} from your friends?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeFriend(friend);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
