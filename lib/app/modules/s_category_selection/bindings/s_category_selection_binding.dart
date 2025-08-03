import 'package:get/get.dart';

import '../controllers/s_category_selection_controller.dart';

class SCategorySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SCategorySelectionController>(
      () => SCategorySelectionController(),
    );
  }
}
