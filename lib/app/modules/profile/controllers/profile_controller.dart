import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';
import 'package:mindrena/app/services/auth_service.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController

  final user = Rxn<UserModel>(); // Reactive variable to hold user data
  var isLoading = true.obs; // To show a loading indicator
  var userCoins =
      0.obs; // Reactive variable for coins (independent from points)
  var selectedTab = 0.obs; // For tab selection in profile
  var purchasedItems = <String>[].obs;
  var purchasedAvatars = <Map<String, String>>[].obs;
  var purchasedStickers = <Map<String, String>>[].obs;
  var trophies = <Map<String, String>>[].obs;

  // Use shared auth service instead of individual instances
  final AuthService _authService = AuthService.instance;

  @override
  void onInit() async {
    super.onInit();
    await fetchUserProfile(); // Fetch user profile when the controller is initialized
    await _loadPurchasedItems(); // Load purchased items
    isLoading.value = false; // Stop loading after fetching
  }

  Future<void> fetchUserProfile() async {
    // Simulate fetching user profile data
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore
          .collection('users')
          .doc(
            FirebaseAuth.instance.currentUser?.uid,
          ) // Assuming UserModel has an 'id' field
          .get()
          .then((DocumentSnapshot document) {
            if (document.exists) {
              user.value = UserModel.fromMap(
                document.data() as Map<String, dynamic>,
              );
              // Get coins directly from user stats (no longer calculated from points)
              userCoins.value = user.value?.coins ?? 0;
            } else {
              print("User does not exist");
            }
          });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  /// Load purchased items from Firestore
  Future<void> _loadPurchasedItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        // Load purchased items
        purchasedItems.value = List<String>.from(
          userData['purchasedItems'] ?? [],
        );

        // Load purchased avatars
        purchasedAvatars.value = List<Map<String, String>>.from(
          (userData['purchasedAvatars'] ?? []).map(
            (item) => Map<String, String>.from(item),
          ),
        );

        // Load purchased stickers
        purchasedStickers.value = List<Map<String, String>>.from(
          (userData['purchasedStickers'] ?? []).map(
            (item) => Map<String, String>.from(item),
          ),
        );

        // Load trophies (placeholder for now)
        trophies.value = [
          if (this.user.value?.gamesWon != null &&
              this.user.value!.gamesWon > 0)
            {
              'id': 'first_win',
              'name': 'First Victory',
              'description': 'Won your first game!',
            },
          if (this.user.value?.gamesWon != null &&
              this.user.value!.gamesWon >= 10)
            {
              'id': 'win_streak',
              'name': 'Game Master',
              'description': 'Won 10 games!',
            },
          if (this.user.value?.totalPoints != null &&
              this.user.value!.totalPoints >= 1000)
            {
              'id': 'point_collector',
              'name': 'Point Collector',
              'description': 'Earned 1000+ points!',
            },
        ];
      }
    } catch (e) {
      print('Error loading purchased items: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  /// Change tab in profile view
  void changeTab(int index) {
    selectedTab.value = index;
  }
}
