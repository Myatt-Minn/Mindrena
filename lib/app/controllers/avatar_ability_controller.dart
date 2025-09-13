import 'package:get/get.dart';
import 'package:mindrena/app/data/shopItemModel.dart';

/// Controller to manage selected avatar abilities for games
class AvatarAbilityController extends GetxController {
  // Currently selected avatar ability for the next game
  var selectedAbility = Rx<AvatarAbility?>(null);

  // Track if ability has been used in current game
  var abilityUsed = false.obs;

  /// Set the selected ability for the next game
  void selectAbility(AvatarAbility? ability) {
    selectedAbility.value = ability;
    abilityUsed.value = false; // Reset usage status
  }

  /// Use the ability (call this when player activates it in game)
  void useAbility() {
    abilityUsed.value = true;
  }

  /// Reset ability usage for new game
  void resetForNewGame() {
    abilityUsed.value = false;
  }

  /// Check if ability can be used
  bool canUseAbility() {
    return selectedAbility.value != null && !abilityUsed.value;
  }

  /// Get the current ability type
  AbilityType? getCurrentAbilityType() {
    return selectedAbility.value?.type;
  }

  /// Get ability effects
  Map<String, dynamic>? getAbilityEffects() {
    return selectedAbility.value?.effects;
  }
}
