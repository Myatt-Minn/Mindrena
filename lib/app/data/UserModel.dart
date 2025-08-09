class UserModel {
  String? uid;
  String username;
  String email;
  String avatarUrl;
  String? currentGameId;
  String? role; // Optional role field
  Map<String, dynamic> stats;

  UserModel({
    this.uid,
    required this.username,
    required this.email,
    required this.avatarUrl,
    this.currentGameId,
    this.role, // Optional role field
    required this.stats,
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
}
