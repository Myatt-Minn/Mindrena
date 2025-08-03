import 'package:get/get.dart';

import '../controllers/player_mode_selection_controller.dart';

class PlayerModeSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayerModeSelectionController>(
      () => PlayerModeSelectionController(),
    );
  }
}
