import 'package:get/get.dart';
import 'package:mindrena/app/data/PaymentModel.dart';

class PaymentSelectionController extends GetxController {
  // Selected coin package from previous screen
  var selectedPackage = Rxn<dynamic>();

  // Available payment methods
  var paymentMethods = <PaymentMethod>[].obs;

  // Selected payment method
  var selectedPaymentMethod = Rxn<PaymentMethod>();

  @override
  void onInit() {
    super.onInit();

    // Get the package from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['package'] != null) {
      selectedPackage.value = args['package'];
    }

    _initializePaymentMethods();
  }

  void _initializePaymentMethods() {
    paymentMethods.value = [
      PaymentMethod(
        id: 'promptpay',
        name: 'PromptPay',
        description: 'Pay with PromptPay QR Code',
        icon: 'assets/PromptPay-logo.png', // You'll need to add this asset
        accountName: 'Mindrena Game Store',
        phoneNumber: '0814517593',
        qrCodeUrl: 'assets/PromptPayQR.jpeg', // You'll need to add this asset
      ),
      PaymentMethod(
        id: 'kpay',
        name: 'KPay',
        description: 'Pay with KPay Mobile Banking',
        icon: 'assets/kpayLogo.png', // You'll need to add this asset
        accountName: 'Mindrena Game Store',
        phoneNumber: '09780293819',
        qrCodeUrl: 'assets/KpayQR.jpeg', // You'll need to add this asset
      ),
    ];
  }

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  void proceedToCheckout() {
    if (selectedPaymentMethod.value == null) {
      Get.snackbar('Error', 'Please select a payment method');
      return;
    }

    Get.toNamed(
      '/checkout',
      arguments: {
        'package': selectedPackage.value,
        'paymentMethod': selectedPaymentMethod.value,
      },
    );
  }
}
