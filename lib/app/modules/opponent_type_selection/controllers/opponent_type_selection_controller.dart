import 'package:get/get.dart';
import 'package:mindrena/app/modules/home/controllers/home_controller.dart';

class OpponentTypeSelectionController extends GetxController {
  //TODO: Implement OpponentTypeSelectionController

  var isLoading = false.obs; // To show a loading indicator

  Future<void> inviteFriend(String category) async {
    try {
      isLoading.value = true; // Start loading
      final homeController = Get.find<HomeController>();
      await homeController.quickInviteFriends(category);

      isLoading.value = false; // Stop loading after the operation
    } catch (e) {
      // If HomeController is not found, show error
      Get.snackbar(
        'Error',
        'Failed to invite friends: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false; // Stop loading on error
    }
  }
}
