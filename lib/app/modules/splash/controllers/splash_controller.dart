import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onReady() async {
    super.onReady();
    box.remove('repeat'); // Clear the 'repeat' key on every app start
    await Future.delayed(const Duration(seconds: 4), () {
      checkFirstTime();
    });
  }

  void checkFirstTime() async {
    final bool? repeat = box.read('repeat');
    if (repeat == null) {
      await box.write('repeat', true);
      Get.offAllNamed('/player-mode-selection');
    } else {
      Get.offAllNamed('/gate');
    }
  }
}
