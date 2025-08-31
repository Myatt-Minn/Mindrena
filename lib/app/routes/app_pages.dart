import 'package:get/get.dart';
import 'package:mindrena/app/modules/single_player/sg_f_category_selection/bindings/sg_f_category_selection_binding.dart';
import 'package:mindrena/app/modules/single_player/sg_f_category_selection/views/sg_f_category_selection_view.dart';
import 'package:mindrena/app/modules/single_player/sg_f_difficulty_selection/bindings/sg_f_difficulty_selection_binding.dart';
import 'package:mindrena/app/modules/single_player/sg_f_difficulty_selection/views/sg_f_difficulty_selection_view.dart';
import 'package:mindrena/app/modules/single_player/sg_home/bindings/sg_home_binding.dart';
import 'package:mindrena/app/modules/single_player/sg_home/views/sg_home_view.dart';
import 'package:mindrena/app/modules/single_player/sg_quiz/bindings/sg_quiz_binding.dart';
import 'package:mindrena/app/modules/single_player/sg_quiz/views/sg_quiz_view.dart';

import '../modules/auth_gate/bindings/auth_gate_binding.dart';
import '../modules/auth_gate/views/auth_gate_view.dart';
import '../modules/auth_gate/views/no_internet.dart';
import '../modules/edit-profile/bindings/edit_profile_binding.dart';
import '../modules/edit-profile/views/edit_profile_view.dart';
import '../modules/f_category_selection/bindings/f_category_selection_binding.dart';
import '../modules/f_category_selection/views/f_category_selection_view.dart';
import '../modules/friends/bindings/friends_binding.dart';
import '../modules/friends/views/friends_view.dart';
import '../modules/g_category_selection/bindings/g_category_selection_binding.dart';
import '../modules/g_category_selection/views/g_category_selection_view.dart';
import '../modules/game_screen/bindings/game_screen_binding.dart';
import '../modules/game_screen/views/game_screen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/lobby/bindings/lobby_binding.dart';
import '../modules/lobby/views/lobby_view.dart';
import '../modules/m_category_selection/bindings/m_category_selection_binding.dart';
import '../modules/m_category_selection/views/m_category_selection_view.dart';
import '../modules/memorize_image_game_screen/bindings/memorize_image_game_screen_binding.dart';
import '../modules/memorize_image_game_screen/views/memorize_image_game_screen_view.dart';
import '../modules/opponent_type_selection/bindings/opponent_type_selection_binding.dart';
import '../modules/opponent_type_selection/views/opponent_type_selection_view.dart';
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
import '../modules/user_feedback/bindings/user_feedback_binding.dart';
import '../modules/user_feedback/views/user_feedback_view.dart';
import '../modules/user_guides/bindings/user_guides_binding.dart';
import '../modules/user_guides/views/user_guides_view.dart';

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
    GetPage(
      name: _Paths.USER_GUIDES,
      page: () => const UserGuidesView(),
      binding: UserGuidesBinding(),
    ),
    GetPage(
      name: _Paths.USER_FEEDBACK,
      page: () => const UserFeedbackView(),
      binding: UserFeedbackBinding(),
    ),
    GetPage(
      name: _Paths.OPPONENT_TYPE_SELECTION,
      page: () => const OpponentTypeSelectionView(),
      binding: OpponentTypeSelectionBinding(),
    ),
    GetPage(
      name: _Paths.G_CATEGORY_SELECTION,
      page: () => const GCategorySelectionView(),
      binding: GCategorySelectionBinding(),
    ),
    GetPage(
      name: _Paths.MEMORIZE_IMAGE_GAME_SCREEN,
      page: () => const MemorizeImageGameScreenView(),
      binding: MemorizeImageGameScreenBinding(),
    ),
    GetPage(
      name: _Paths.SINGLE_PLAYER,
      page: () => const SgHomeView(),
      binding: SgHomeBinding(),
    ),
    GetPage(
      name: _Paths.SG_HOME,
      page: () => const SgHomeView(),
      binding: SgHomeBinding(),
    ),
    GetPage(
      name: _Paths.SG_F_CATEGORY_SELECTION,
      page: () => const SgFCategorySelectionView(),
      binding: SgFCategorySelectionBinding(),
    ),
    GetPage(
      name: _Paths.SG_F_DIFFICULTY_SELECTION,
      page: () => const SgFDifficultySelectionView(),
      binding: SgFDifficultySelectionBinding(),
    ),
    GetPage(
      name: _Paths.SG_QUIZ,
      page: () => const SgQuizView(),
      binding: SgQuizBinding(),
    ),
  ];
}
