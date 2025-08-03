import 'package:get/get.dart';

import '../controllers/m_category_selection_controller.dart';

class MCategorySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MCategorySelectionController>(
      () => MCategorySelectionController(),
    );
  }
}
