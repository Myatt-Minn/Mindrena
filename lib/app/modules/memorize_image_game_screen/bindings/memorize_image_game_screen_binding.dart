import 'package:get/get.dart';

import '../controllers/memorize_image_game_screen_controller.dart';

class MemorizeImageGameScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemorizeImageGameScreenController>(
      () => MemorizeImageGameScreenController(),
    );
  }
}
