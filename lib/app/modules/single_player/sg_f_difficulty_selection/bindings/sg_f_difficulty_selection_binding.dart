import 'package:get/get.dart';

import '../controllers/sg_f_difficulty_selection_controller.dart';

class SgFDifficultySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SgFDifficultySelectionController>(
      () => SgFDifficultySelectionController(),
    );
  }
}
