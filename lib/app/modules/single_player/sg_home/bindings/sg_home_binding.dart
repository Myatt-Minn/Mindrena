import 'package:get/get.dart';

import '../controllers/sg_home_controller.dart';

class SgHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SgHomeController>(
      () => SgHomeController(),
    );
  }
}
