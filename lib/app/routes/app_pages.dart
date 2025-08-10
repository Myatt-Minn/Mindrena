import 'package:get/get.dart';

import '../modules/auth_gate/bindings/auth_gate_binding.dart';
import '../modules/auth_gate/views/auth_gate_view.dart';
import '../modules/auth_gate/views/no_internet.dart';
import '../modules/edit-profile/bindings/edit_profile_binding.dart';
import '../modules/edit-profile/views/edit_profile_view.dart';
import '../modules/f_category_selection/bindings/f_category_selection_binding.dart';
import '../modules/f_category_selection/views/f_category_selection_view.dart';
import '../modules/friends/bindings/friends_binding.dart';
import '../modules/friends/views/friends_view.dart';
import '../modules/game_screen/bindings/game_screen_binding.dart';
import '../modules/game_screen/views/game_screen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/lobby/bindings/lobby_binding.dart';
import '../modules/lobby/views/lobby_view.dart';
import '../modules/m_category_selection/bindings/m_category_selection_binding.dart';
import '../modules/m_category_selection/views/m_category_selection_view.dart';
import '../modules/player_mode_selection/bindings/player_mode_selection_binding.dart';
import '../modules/player_mode_selection/views/player_mode_selection_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/s_category_selection/bindings/s_category_selection_binding.dart';
import '../modules/s_category_selection/views/s_category_selection_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/shop/bindings/shop_binding.dart';
import '../modules/shop/views/shop_view.dart';
import '../modules/sign-in/bindings/sign_in_binding.dart';
import '../modules/sign-in/views/sign_in_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_IN,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_GATE,
      page: () => const AuthGateView(),
      binding: AuthGateBinding(),
    ),
    GetPage(
      name: _Paths.NO_CONNECTION,
      page: () => const NoInternetScreen(),
      binding: AuthGateBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.S_CATEGORY_SELECTION,
      page: () => const SCategorySelectionView(),
      binding: SCategorySelectionBinding(),
    ),
    GetPage(
      name: _Paths.M_CATEGORY_SELECTION,
      page: () => const MCategorySelectionView(),
      binding: MCategorySelectionBinding(),
    ),
    GetPage(
      name: _Paths.F_CATEGORY_SELECTION,
      page: () => const FCategorySelectionView(),
      binding: FCategorySelectionBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.PLAYER_MODE_SELECTION,
      page: () => const PlayerModeSelectionView(),
      binding: PlayerModeSelectionBinding(),
    ),
    GetPage(
      name: _Paths.LOBBY,
      page: () => const LobbyView(),
      binding: LobbyBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.GAME_SCREEN,
      page: () => const GameScreenView(),
      binding: GameScreenBinding(),
    ),
    GetPage(
      name: _Paths.SHOP,
      page: () => const ShopView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: _Paths.FRIENDS,
      page: () => const FriendsView(),
      binding: FriendsBinding(),
    ),
  ];
}
