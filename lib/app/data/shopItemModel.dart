/// Avatar special abilities
class AvatarAbility {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final AbilityType type;
  final Map<String, dynamic> effects; // Stores ability-specific parameters

  AvatarAbility({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.effects,
  });
}

/// Types of special abilities
enum AbilityType {
  skipQuestion, // Skip current question with no penalty
  extraTime, // Add extra time to current question
  showHint, // Show a hint for current question
  eliminate50, // Remove 2 wrong answers (50/50)
  freezeOpponent, // Freeze opponent for current question
  doublePoints, // Double points for current question
}

/// Shop item model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final ShopItemType type;
  final AvatarAbility? specialAbility; // Add special ability for avatars

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.type,
    this.specialAbility, // Optional, only used for avatars
  });
}

/// Shop item types
enum ShopItemType { avatar, sticker }
