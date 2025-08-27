class UserModel {
  String? uid;
  String username;
  String email;
  String avatarUrl;
  String? currentGameId;
  String? role; // Optional role field
  Map<String, dynamic> stats;
  List<String> friends; // List of friend UIDs
  List<String> friendRequests; // List of pending friend request UIDs
  List<String> sentRequests; // List of sent friend request UIDs

  UserModel({
    this.uid,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.currentGameId,
    this.role, // Optional role field
    required this.stats,
    this.friends = const [],
    this.friendRequests = const [],
    this.sentRequests = const [],
  });

  // Convert UserModel to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'currentGameId': currentGameId,
      'role': role, // Include role in the map
      'stats': stats,
      'friends': friends,
      'friendRequests': friendRequests,
      'sentRequests': sentRequests,
    };
  }

  // fromMap function to convert Firestore data to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      currentGameId: map['currentGameId'],
      role: map['role'], // Optional role field
      stats:
          map['stats'] ?? {'gamesPlayed': 0, 'gamesWon': 0, 'totalPoints': 0},
      friends: List<String>.from(map['friends'] ?? []),
      friendRequests: List<String>.from(map['friendRequests'] ?? []),
      sentRequests: List<String>.from(map['sentRequests'] ?? []),
    );
  }

  // Helper methods to access stats easily
  int get gamesPlayed => stats['gamesPlayed'] ?? 0;
  int get gamesWon => stats['gamesWon'] ?? 0;
  int get totalPoints => stats['totalPoints'] ?? 0;

  // Helper method to calculate win rate
  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  // Helper methods to update stats
  void updateStats({int? gamesPlayed, int? gamesWon, int? totalPoints}) {
    if (gamesPlayed != null) stats['gamesPlayed'] = gamesPlayed;
    if (gamesWon != null) stats['gamesWon'] = gamesWon;
    if (totalPoints != null) stats['totalPoints'] = totalPoints;
  }

  void incrementGamesPlayed() {
    stats['gamesPlayed'] = (stats['gamesPlayed'] ?? 0) + 1;
  }

  void incrementGamesWon() {
    stats['gamesWon'] = (stats['gamesWon'] ?? 0) + 1;
  }

  void addPoints(int points) {
    stats['totalPoints'] = (stats['totalPoints'] ?? 0) + points;
  }

  // Friend management helper methods
  bool isFriend(String uid) => friends.contains(uid);
  bool hasPendingRequest(String uid) => friendRequests.contains(uid);
  bool hasSentRequest(String uid) => sentRequests.contains(uid);

  void addFriend(String uid) {
    if (!friends.contains(uid)) {
      friends = [...friends, uid];
    }
  }

  void removeFriend(String uid) {
    friends = friends.where((id) => id != uid).toList();
  }

  void addFriendRequest(String uid) {
    if (!friendRequests.contains(uid)) {
      friendRequests = [...friendRequests, uid];
    }
  }

  void removeFriendRequest(String uid) {
    friendRequests = friendRequests.where((id) => id != uid).toList();
  }

  void addSentRequest(String uid) {
    if (!sentRequests.contains(uid)) {
      sentRequests = [...sentRequests, uid];
    }
  }

  void removeSentRequest(String uid) {
    sentRequests = sentRequests.where((id) => id != uid).toList();
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? avatarUrl,
    String? currentGameId,
    String? role,
    Map<String, dynamic>? stats,
    List<String>? friends,
    List<String>? friendRequests,
    List<String>? sentRequests,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentGameId: currentGameId ?? this.currentGameId,
      role: role ?? this.role,
      stats: stats ?? this.stats,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      sentRequests: sentRequests ?? this.sentRequests,
    );
  }
}
