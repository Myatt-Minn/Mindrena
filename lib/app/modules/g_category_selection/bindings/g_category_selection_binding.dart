import 'package:get/get.dart';

import '../controllers/g_category_selection_controller.dart';

class GCategorySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GCategorySelectionController>(
      () => GCategorySelectionController(),
    );
  }
}
