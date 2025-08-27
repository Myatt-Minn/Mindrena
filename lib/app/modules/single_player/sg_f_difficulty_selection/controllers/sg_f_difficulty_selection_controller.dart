import 'package:get/get.dart';

class SgFDifficultySelectionController extends GetxController {
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      selectedCategory.value = Get.arguments as String;
    }
  }
}
