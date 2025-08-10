import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindrena/app/data/MyTranslations.dart';
import 'package:mindrena/app/data/consts_config.dart';
import 'package:mindrena/app/data/sendNotificationHandler.dart';
import 'package:mindrena/app/modules/splash/bindings/splash_binding.dart';
import 'package:mindrena/firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SendNotificationHandler.initialized();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      name: "agrilibmm",
    );
  }

  SendNotificationHandler.initialized();
  await SendNotificationHandler().initNotification();
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  final storage = GetStorage();
  bool isDarkMode = storage.read('darkMode') ?? false; // Read saved preference

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    GetStorage().remove('language'); // Clear language setting on app start
    String? savedLanguage = GetStorage().read('language') ?? 'ENG';

    runApp(
      GetMaterialApp(
        translations: MyTranslations(),
        // Set the locale dynamically based on the saved languagek
        locale: savedLanguage == 'ENG'
            ? const Locale('en', 'US')
            : const Locale('my', 'MM'),
        fallbackLocale: const Locale(
          'en',
          'US',
        ), // Set a fallback language (e.g., English)
        title: ConstsConfig.appname,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        //initialRoute: isFirstTime ? AppPages.ON_BOARDING : AppPages.MY_HOME,
        initialRoute: AppPages.INITIAL,
        initialBinding: SplashBinding(),
        getPages: AppPages.routes,
      ),
    );
  });
}
