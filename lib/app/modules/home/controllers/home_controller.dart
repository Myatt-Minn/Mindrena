import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/AdDataModel.dart';
import 'package:mindrena/app/data/adOnboardingDialog.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController
  var isAdDialogShown = false.obs;
  final GetStorage _storage = GetStorage();

  @override
  void onInit() async {
    super.onInit();
    // Initialize the controller and check for ads
    await _checkAndShowAdDialog();
  }

  // Check if ad dialog should be shown
  Future<void> _checkAndShowAdDialog() async {
    try {
      // Check if this is the user's first time using the app
      bool isFirstTime = _storage.read('is_first_time') ?? true;

      if (isFirstTime) {
        // Mark that the user has opened the app for the first time
        _storage.write('is_first_time', false);
        print('First time user - skipping ad dialog');
        return;
      }

      // Check if dialog was already shown today
      String today = DateTime.now().toIso8601String().split('T')[0];

      // Fetch ads from Firebase
      List<AdData> ads = await _fetchActiveAds();

      if (ads.isNotEmpty && !isAdDialogShown.value) {
        isAdDialogShown.value = true;

        await Get.dialog(
          AdOnboardingDialog(
            ads: ads,
            onComplete: () {
              // Save the date when dialog was shown
              _storage.write('last_ad_shown_date', today);
              isAdDialogShown.value = false;
            },
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Error showing ad dialog: $e');
    }
  }

  // Fetch active ads from Supabase
  Future<List<AdData>> _fetchActiveAds() async {
    try {
      final response = await FirebaseFirestore.instance
          .collection('app_ads')
          .get();

      List<AdData> ads = [];
      for (var item in response.docs) {
        ads.add(AdData.fromJson(item.data()));
      }

      return ads;
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }
}
