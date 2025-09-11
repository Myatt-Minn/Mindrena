/// Coin package model for purchase
class CoinPackage {
  final String id;
  final int coins;
  final double price; // Price in THB
  final double mmkPrice; // Fixed price in MMK
  final double? originalPrice; // Original price for discount display
  final bool isPopular;

  CoinPackage({
    required this.id,
    required this.coins,
    required this.price,
    required this.mmkPrice,
    this.originalPrice,
    this.isPopular = false,
  });

  // Calculate discount percentage
  int get discountPercentage {
    if (originalPrice == null) return 0;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }
}
