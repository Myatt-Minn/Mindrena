import 'package:get/get.dart';

import '../controllers/guess_it_fast_controller.dart';

class GuessItFastBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuessItFastController>(
      () => GuessItFastController(),
    );
  }
}
