import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;

  Future<void> signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/sign-in');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}
