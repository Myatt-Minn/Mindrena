import 'package:get/get.dart';

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'checking_authentication': 'Checking authentication...',
      'checking_connection': 'Checking connection...',
    },
    'my_MM': {
      'checking_authentication': 'အတည်ပြုမှုကိုစစ်ဆေးနေသည်...',
      'checking_connection': 'ချိတ်ဆက်မှုကိုစစ်ဆေးနေသည်...',
    },
  };
}
