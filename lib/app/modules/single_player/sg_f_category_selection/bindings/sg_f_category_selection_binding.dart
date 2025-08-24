import 'package:get/get.dart';

import '../controllers/sg_f_category_selection_controller.dart';

class SgFCategorySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SgFCategorySelectionController>(
      () => SgFCategorySelectionController(),
    );
  }
}
