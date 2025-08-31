import 'package:get/get.dart';

class SgFCategorySelectionController extends GetxController {
  var selectedType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedType.value = Get.arguments;
  }
}
