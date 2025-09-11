import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/data/consts_config.dart';
import 'package:mindrena/app/utils/number_formatter.dart';

class LeaderBoardController extends GetxController {
  var isLoading = true.obs;
  var users = <UserModel>[].obs;
  var filteredUsers = <UserModel>[].obs;
  var selectedFilter = 'totalPoints'.obs;
  var currentUserRank = 0.obs;
  var searchQuery = ''.obs;

  final storage = GetStorage();
  final currentUser = Rxn<UserModel>();

  final TextEditingController searchController = TextEditingController();

  final List<String> filterOptions = [
    'totalPoints',
    'gamesWon',
    'gamesPlayed',
    'winRate',
    'coins',
  ];

  final Map<String, String> filterLabels = {
    'totalPoints': 'Total Points',
    'gamesWon': 'Won',
    'gamesPlayed': 'Played',
    'winRate': 'Win Rate',
    'coins': 'Coins',
  };

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    loadLeaderboard();

    // Listen to search changes
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _filterUsers();
  }

  void loadCurrentUser() {
    try {
      final userData = storage.read('user');
      if (userData != null) {
        currentUser.value = UserModel.fromMap(userData);
        print('Current user loaded: ${currentUser.value?.username}');
      } else {
        // Fallback to Firebase Auth
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          _loadUserFromFirestore(firebaseUser.uid);
        }
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadUserFromFirestore(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        currentUser.value = UserModel.fromMap(userDoc.data()!);
        await storage.write('user', currentUser.value!.toMap());
      }
    } catch (e) {
      print('Error loading user from Firestore: $e');
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      isLoading.value = true;

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      List<UserModel> userList = [];

      for (var doc in snapshot.docs) {
        try {
          final userData = doc.data() as Map<String, dynamic>;
          final user = UserModel.fromMap(userData);

          // Only add users who have played at least one game or have any stats
          if (user.gamesPlayed > 0 || user.totalPoints > 0 || user.coins > 0) {
            userList.add(user);
          }
        } catch (e) {
          print('Error parsing user ${doc.id}: $e');
        }
      }

      users.value = userList;
      print('Loaded ${userList.length} users for leaderboard');

      _sortAndFilterUsers();
      _calculateCurrentUserRank();
    } catch (e) {
      print('Error loading leaderboard: $e');
      Get.snackbar(
        'Error',
        'Failed to load leaderboard data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    _sortAndFilterUsers();
    _calculateCurrentUserRank();
  }

  void _sortAndFilterUsers() {
    List<UserModel> sortedUsers = List.from(users);

    // Sort based on selected filter
    switch (selectedFilter.value) {
      case 'totalPoints':
        sortedUsers.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        break;
      case 'gamesWon':
        sortedUsers.sort((a, b) => b.gamesWon.compareTo(a.gamesWon));
        break;
      case 'gamesPlayed':
        sortedUsers.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
        break;
      case 'winRate':
        sortedUsers.sort((a, b) => b.winRate.compareTo(a.winRate));
        break;
      case 'coins':
        sortedUsers.sort((a, b) => b.coins.compareTo(a.coins));
        break;
    }

    _filterUsers(sortedUsers);
  }

  void _filterUsers([List<UserModel>? userList]) {
    List<UserModel> usersToFilter = userList ?? List.from(users);

    if (searchQuery.value.isNotEmpty) {
      usersToFilter = usersToFilter.where((user) {
        return user.username.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            user.email.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    filteredUsers.value = usersToFilter;
  }

  void _calculateCurrentUserRank() {
    if (currentUser.value == null) return;

    for (int i = 0; i < filteredUsers.length; i++) {
      if (filteredUsers[i].uid == currentUser.value!.uid) {
        currentUserRank.value = i + 1;
        break;
      }
    }
  }

  String getFilterValue(UserModel user, String filter) {
    switch (filter) {
      case 'totalPoints':
        return user.totalPoints.formatCompact();
      case 'gamesWon':
        return user.gamesWon.formatCompact();
      case 'gamesPlayed':
        return user.gamesPlayed.formatCompact();
      case 'winRate':
        return user.winRate.formatPercentage();
      case 'coins':
        return user.coins.formatCompact();
      default:
        return '0';
    }
  }

  Color getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  IconData getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.military_tech; // Medal
      default:
        return Icons.person;
    }
  }

  Future<void> refreshLeaderboard() async {
    await loadLeaderboard();
  }

  bool isCurrentUser(UserModel user) {
    return currentUser.value?.uid == user.uid;
  }

  // Additional helper methods for enhanced leaderboard features
  String getUserRankSuffix(int rank) {
    if (rank % 100 >= 11 && rank % 100 <= 13) {
      return '${rank}th';
    }
    switch (rank % 10) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }

  String getMotivationalMessage(int rank, int totalUsers) {
    if (rank == 1) {
      return "🏆 Champion! You're the best!";
    } else if (rank <= 3) {
      return "🥇 Amazing! You're in the top 3!";
    } else if (rank <= 10) {
      return "⭐ Great job! You're in the top 10!";
    } else if (rank <= totalUsers * 0.25) {
      return "🚀 Well done! You're in the top 25%!";
    } else if (rank <= totalUsers * 0.5) {
      return "📈 Good progress! You're in the top 50%!";
    } else {
      return "💪 Keep playing to climb higher!";
    }
  }

  Color getScoreColor(String filter, UserModel user) {
    switch (filter) {
      case 'totalPoints':
        if (user.totalPoints >= 1000) return Colors.purple;
        if (user.totalPoints >= 500) return Colors.blue;
        if (user.totalPoints >= 100) return Colors.green;
        return Colors.grey;
      case 'winRate':
        if (user.winRate >= 80) return Colors.green;
        if (user.winRate >= 60) return Colors.blue;
        if (user.winRate >= 40) return Colors.orange;
        return Colors.red;
      default:
        return ConstsConfig.primarycolor;
    }
  }
}
