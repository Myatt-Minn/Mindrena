import 'package:get/get.dart';

import '../controllers/user_guides_controller.dart';

class UserGuidesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserGuidesController>(
      () => UserGuidesController(),
    );
  }
}
