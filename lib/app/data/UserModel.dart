class UserModel {
  String? uid;
  String username;
  String email;
  String phone;
  String role;
  String profileImg;

  UserModel({
    this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.profileImg,
  });

  // Convert UserModel to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImg': profileImg,
    };
  }

  // fromMap function to convert Firestore data to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      profileImg: map['profileImg'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
