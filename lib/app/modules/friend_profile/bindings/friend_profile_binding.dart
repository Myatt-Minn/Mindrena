import 'package:get/get.dart';

import '../controllers/friend_profile_controller.dart';

class FriendProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FriendProfileController>(() => FriendProfileController());
  }
}
