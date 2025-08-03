import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/UserModel.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController

  final user = Rxn<UserModel>(); // Reactive variable to hold user data
  var isLoading = true.obs; // To show a loading indicator

  @override
  void onInit() async {
    super.onInit();
    await fetchUserProfile(); // Fetch user profile when the controller is initialized
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
            } else {
              print("User does not exist");
            }
          });
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }
}
