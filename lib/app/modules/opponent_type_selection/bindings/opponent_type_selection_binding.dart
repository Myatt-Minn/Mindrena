import 'package:get/get.dart';

import '../controllers/opponent_type_selection_controller.dart';

class OpponentTypeSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OpponentTypeSelectionController>(
      () => OpponentTypeSelectionController(),
    );
  }
}
