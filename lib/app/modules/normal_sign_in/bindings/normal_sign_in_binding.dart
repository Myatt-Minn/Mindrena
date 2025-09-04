import 'package:get/get.dart';

import '../controllers/normal_sign_in_controller.dart';

class NormalSignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NormalSignInController>(
      () => NormalSignInController(),
    );
  }
}
