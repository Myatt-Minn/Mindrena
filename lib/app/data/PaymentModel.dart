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
