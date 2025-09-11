import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlayerModeSelectionController extends GetxController {
  // Observable variables
  final selectedLanguage = 'ENG'.obs;
  final isLoaded = false.obs;

  // Storage instance
  final storage = GetStorage();

  // Get the display name for the selected language
  String get currentLanguageDisplay {
    switch (selectedLanguage.value) {
      case 'ENG':
        return 'English';
      case 'MYN':
        return 'Myanmar';
      case 'TH':
        return 'Thai';
      default:
        return 'English'; // Default to English
    }
  }

  @override
  void onInit() async {
    super.onInit();
    // Load saved language preference
    _loadSavedLanguage();
  }

  @override
  void onReady() {
    super.onReady();
    // Preload images after the controller is ready
    _preloadImages();
    // Update locale after everything is initialized
    updateLocale();
  }

  /// Load saved language preference from storage
  void _loadSavedLanguage() {
    final savedLanguage = storage.read('language');
    if (savedLanguage != null &&
        (savedLanguage == 'ENG' ||
            savedLanguage == 'MYN' ||
            savedLanguage == 'TH')) {
      selectedLanguage.value = savedLanguage;
    }
  }

  /// Preload images to avoid loading delays
  Future<void> _preloadImages() async {
    try {
      // Use a proper context from Get if available, otherwise skip preloading
      final context = Get.context;
      if (context != null) {
        await precacheImage(const AssetImage('assets/two_player.gif'), context);
        await precacheImage(
          const AssetImage('assets/single_player.gif'),
          context,
        );
      }
      isLoaded.value = true;
    } catch (e) {
      // If preloading fails, still mark as loaded
      isLoaded.value = true;
      print('Image preloading failed: $e');
    }
  }

  /// Update app locale based on selected language
  void updateLocale() {
    final locale = selectedLanguage.value == 'ENG'
        ? const Locale('en', 'US')
        : selectedLanguage.value == 'MYN'
        ? const Locale('my', 'MM')
        : const Locale('th', 'TH');

    Get.updateLocale(locale);
  }

  /// Toggle language and save preference
  void toggleLanguage(String language) {
    if (language == 'ENG' || language == 'MYN' || language == 'TH') {
      selectedLanguage.value = language;
      storage.write('language', language);
      updateLocale();
    }
  }
}
