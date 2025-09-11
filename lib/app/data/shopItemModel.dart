/// Shop item model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final ShopItemType type;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
  });
}

/// Shop item types
enum ShopItemType { avatar, sticker }
