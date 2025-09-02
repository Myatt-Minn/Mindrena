import 'package:get/get.dart';

class SgFDifficultySelectionController extends GetxController {
  var selectedCategory = ''.obs;
  var selectedType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      selectedCategory.value = Get.arguments['category'];
      selectedType.value = Get.arguments['type'];
    }
  }
}
