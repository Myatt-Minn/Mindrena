import 'package:get/get.dart';

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
        icon: 'assets/promptpay_logo.png', // You'll need to add this asset
        accountName: 'Mindrena Game Store',
        phoneNumber: '086-123-4567',
        qrCodeUrl: 'assets/promptpay_qr.png', // You'll need to add this asset
      ),
      PaymentMethod(
        id: 'kpay',
        name: 'KPay',
        description: 'Pay with KPay Mobile Banking',
        icon: 'assets/kpay_logo.png', // You'll need to add this asset
        accountName: 'Mindrena Game Store',
        phoneNumber: '086-123-4567',
        qrCodeUrl: 'assets/kpay_qr.png', // You'll need to add this asset
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

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String accountName;
  final String phoneNumber;
  final String qrCodeUrl;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accountName,
    required this.phoneNumber,
    required this.qrCodeUrl,
  });
}
