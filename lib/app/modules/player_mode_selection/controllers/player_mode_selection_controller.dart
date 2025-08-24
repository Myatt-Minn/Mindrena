import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlayerModeSelectionController extends GetxController {
  //TODO: Implement PlayerModeSelectionController

  var selectedLanguage = 'MYN'.obs;
  var languageSelected = 'Myanmar'.obs;

  final storage = GetStorage();

  // Get the display name for the selected language
  String get currentLanguageDisplay {
    switch (selectedLanguage.value) {
      case 'ENG':
        return 'English';
      case 'MYN':
        return 'Myanmar';
      default:
        return 'Myanmar';
    }
  }

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = storage.read('language') ?? 'ENG';
    languageSelected.value = currentLanguageDisplay;

    // Defer the locale update until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateLocale();
    });
  }

  void updateLocale() {
    if (selectedLanguage.value == 'ENG') {
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      Get.updateLocale(const Locale('my', 'MM'));
    }
  }

  void toggleLanguage(String language) {
    selectedLanguage.value = language;
    storage.write('language', language); // Save to storage
    updateLocale(); // Apply the new language

    // Update the language display name
    languageSelected.value = currentLanguageDisplay;
  }
}
