import 'package:get/get.dart';

import '../controllers/sg_quiz_controller.dart';

class SgQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SgQuizController>(
      () => SgQuizController(),
    );
  }
}
