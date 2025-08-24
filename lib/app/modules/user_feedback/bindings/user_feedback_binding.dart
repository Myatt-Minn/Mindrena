import 'package:get/get.dart';

import '../controllers/user_feedback_controller.dart';

class UserFeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserFeedbackController>(
      () => UserFeedbackController(),
    );
  }
}
