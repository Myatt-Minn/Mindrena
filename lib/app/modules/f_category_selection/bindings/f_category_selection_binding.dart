import 'package:get/get.dart';

import '../controllers/f_category_selection_controller.dart';

class FCategorySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FCategorySelectionController>(
      () => FCategorySelectionController(),
    );
  }
}
