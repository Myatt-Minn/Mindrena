import 'package:get/get.dart';

import '../controllers/payment_selection_controller.dart';

class PaymentSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentSelectionController>(
      () => PaymentSelectionController(),
    );
  }
}
