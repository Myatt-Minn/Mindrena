import 'package:get/get.dart';

class MyTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'checking_authentication': 'Checking authentication...',
      'checking_connection': 'Checking connection...',
      // No Internet Screen
      'no_internet_connection': 'No Internet Connection',
      'check_connection_and_try_again':
          'Please check your connection and try again',
      'connection_required': 'Connection Required',
      'connection_required_message':
          'You need an active internet connection to use Mindrena. Please check your WiFi or mobile data connection.',
      'checking': 'Checking...',
      'try_again': 'Try Again',
      'quick_tips': 'Quick Tips:',
      'tip_check_wifi': 'Check your WiFi connection',
      'tip_switch_data': 'Try switching to mobile data',
      'tip_move_closer': 'Move closer to your router',
      'tip_restart_device': 'Restart your device if needed',
      // Ad Dialog
      'cannot_open_website': 'Cannot open the website',
      'cannot_open_website_message':
          'Something wrong with Internet Connection or the app!',

      // User Guides
      'user_guides': 'User Guides',
      'how_can_we_help': 'How can we help?',
      'find_answers_and_learn':
          'Find answers and learn how to use our app effectively.',
      'helpful_guides': 'Helpful Guides',
      'helpful_guides_available': 'Helpful guides available',
      'tap_to_explore': 'Tap to explore',
      'no_guides_available': 'No guides available',
      'check_back_later_for_guides':
          'Check back later for helpful guides and tutorials.',
      'oops_something_went_wrong': 'Oops! Something went wrong',
      'images': 'Images:',
      'image_not_available': 'Image not available',
      'video_tutorial': 'Video Tutorial:',
      'watch_video_tutorial': 'Watch video tutorial',
      'tap_to_open_in_browser': 'Tap to open in browser',
      'last_updated': 'Last updated: @lastUpdated',

      // User Guide Categories
      'category_getting-started': 'Getting Started',
      'category_account': 'Account',
      'category_troubleshooting': 'Troubleshooting',
      'category_friends': 'Friends',
      'category_quizzes': 'Quizzes',
      'category_general': 'General',

      // Lobby
      'lobby': 'Lobby',
      'waiting_for_friend_to_accept':
          'Waiting for @friendName to accept the invitation...',
      'joining_friends_game': 'Joining @friendName\'s game...',
      'looking_for_another_player':
          'Looking for another player in @category...',
      'both_players_joined': 'Both players have joined! Get ready to start!',
      'waiting_for_second_player': 'Waiting for a second player to join...',
      'friend_invitation': 'Friend Invitation',
      'playing_with_friend': 'Playing with Friend',
      'random_match': 'Random Match',
      'player': 'Player',
      'waiting': 'Waiting...',
      'you': 'You',
      'ready': 'Ready',
      'cancel_ready': 'Cancel Ready',
      'ready_to_start': 'Ready to Start!',
      'leave_lobby_q': 'Leave Lobby?',
      'another_player_is_waiting':
          'Another player is waiting. Are you sure you want to leave?',
      'are_you_sure_leave_lobby': 'Are you sure you want to leave the lobby?',
      'stay': 'Stay',
      'leave': 'Leave',
      'leave_lobby': 'Leave Lobby',

      // Single Player Quiz
      'score': 'Score: @score',
      'question_of': 'Question @current of @total',
      'loading_question': 'Loading question...',
      'quiz_summary': 'You answered @score out of @total questions correctly.',
      'quiz_results_summary':
          'You answered @score out of @total questions correctly.',
      'play_again': 'Play Again',
      'exit_game': 'Exit Game',
      'your_answer': 'Your Answer: @answer',
      'correct_answer': 'Correct Answer: @answer',
      'your_aswer': 'Your Answer: @answer', // To handle potential typo
      // Sign In & Feedback
      'welcome_back': 'Welcome back!',
      'signed_in_successfully': 'Signed in successfully',
      'error': 'Error',
      'failed_to_save_user_data': 'Failed to save user data: @error',
      'failed_to_sign_in_google': 'Failed to sign in with Google',
      'google_sign_in_failed': 'Google Sign-In Failed',
      'google_sign_in_error': 'Google Sign-In Error: @error',
      'please_enter_email': 'Please enter your email',
      'please_enter_valid_email': 'Please enter a valid email address',
      'please_enter_password': 'Please enter your password',
      'password_min_length': 'Password must be at least 6 characters long',

      // User Guides Controller
      'error_fetching_guides': 'Error fetching guides: @error',

      // Settings
      'settings': 'Settings',
      'game_settings': 'Game Settings',
      'support': 'Support',
      'about': 'About',
      'language': 'Language',
      'choose_language': 'Choose your preferred language',
      'english': 'English',
      'myanmar': 'Myanmar',
      'sound_effects': 'Sound Effects',
      'enable_disable_sound': 'Enable or disable sound effects',
      'notifications': 'Notifications',
      'receive_updates': 'Receive game updates and challenges',
      'notifications_enabled': 'Notifications enabled',
      'notifications_disabled': 'Notifications disabled',
      'user_guide': 'User Guide',
      'get_help': 'Get help and find answers',
      'send_feedback': 'Send Feedback',
      'share_your_thoughts': 'Share your thoughts with us',
      'rate_app': 'Rate App',
      'rate_us_on_store': 'Rate us on the app store',
      'thank_you_for_support': 'Thank you for your support!',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'read_privacy_policy': 'Read our privacy policy',
      'privacy_policy_soon': 'Privacy policy coming soon!',
      'terms_of_service': 'Terms of Service',
      'read_terms_of_service': 'Read our terms of service',
      'terms_of_service_soon': 'Terms of service coming soon!',
      'all_rights_reserved': '© @year Mindrena. All rights reserved.',

      // User Feedback
      'feedback_performance': 'Performance',
      'feedback_bug_report': 'Bug Report',
      'feedback_feature_request': 'Feature Request',
      'feedback_ui_ux': 'UI/UX',
      'feedback_product_quality': 'Product Quality',
      'feedback_delivery_service': 'Delivery Service',
      'feedback_customer_support': 'Customer Support',
      'feedback_other': 'Other',
      'please_login_to_submit': 'Please login to submit feedback',
      'anonymous_user': 'Anonymous User',
      'feedback_success_title': 'Success',
      'feedback_success_message': 'Feedback submitted successfully!',
      'feedback_error_title': 'Error',
      'feedback_error_message': 'Failed to submit feedback: @error',
      'enter_feedback_title': 'Please enter a title for your feedback',
      'enter_feedback_message': 'Please enter your feedback message',
      'title_min_length': 'Title must be at least 3 characters long',
      'message_min_length':
          'Feedback message must be at least 6 characters long',
      'feedback_deleted_success': 'Feedback deleted successfully',
      'feedback_deleted_error': 'Failed to delete feedback: @error',

      // Feedback Model
      'feedback_type_product': 'Product Review',
      'feedback_type_service': 'Service Feedback',
      'feedback_type_delivery': 'Delivery Feedback',
      'feedback_type_app': 'App Feedback',
      'feedback_type_general': 'General Feedback',
      'feedback_type_default': 'Feedback',
      'feedback_status_pending': 'Pending Review',
      'feedback_status_reviewed': 'Reviewed',
      'feedback_status_resolved': 'Resolved',
      'feedback_status_rejected': 'Rejected',
      'feedback_status_unknown': 'Unknown',

      // Profile
      'sign_out_error': 'Failed to sign out: @error',

      // Auth Service Errors
      'auth_error_google_canceled': 'Sign in was canceled',
      'auth_error_google_interrupted': 'Sign in was interrupted',
      'auth_error_google_client_config': 'Google Sign In configuration error',
      'auth_error_google_provider_config': 'Provider configuration error',
      'auth_error_google_ui_unavailable': 'UI unavailable for sign in',
      'auth_error_google_user_mismatch': 'User mismatch error',
      'auth_error_google_unknown': 'Unknown Google Sign In error',
      'auth_error_firebase_diff_credential':
          'An account already exists with a different sign-in method.',
      'auth_error_firebase_invalid_credential':
          'The credential is invalid or has expired.',
      'auth_error_firebase_op_not_allowed': 'Google sign-in is not enabled.',
      'auth_error_firebase_user_disabled':
          'This user account has been disabled.',
      'auth_error_firebase_user_not_found':
          'No user found with this credential.',
      'auth_error_firebase_wrong_password': 'Invalid password.',
      'auth_error_firebase_invalid_code': 'Invalid verification code.',
      'auth_error_firebase_invalid_id': 'Invalid verification ID.',
      'auth_error_firebase_generic': 'Authentication error (@code): @message',
      'auth_error_google_no_token': 'Failed to get Google ID token',
      'auth_error_unexpected_signin':
          'Unexpected error during Google Sign In: @error',
      'auth_error_no_google_user': 'No Google user signed in',
      'auth_error_scope_request': 'Error requesting scopes: @error',
      'auth_error_server_auth_code': 'Error getting server auth code: @error',
      'auth_error_auth_headers': 'Error getting authorization headers: @error',
      'auth_error_signout': 'Error during sign out: @error',
      'auth_error_disconnect': 'Error during disconnect: @error',

      // Sign In Controller
      'google_user_fallback': 'Google User',

      // Question Model
      'not_available': 'N/A',

      'logout': 'Logout',
      'switch_player_mode': 'Switch Player Mode',
      'profile': 'Profile',
      'shop': 'Shop',
      'friends': 'Friends',
      'account_settings': 'Account Settings',
      'requests': 'Requests',
      'find': 'Find',
      'choose_category': 'Choose Category',
      'edit_profile': 'Edit Profile',
      'game_statistics': 'Game Statistics',
      'choose_your_game': 'Choose Your Game',
    },
    'my_MM': {
      'choose_your_game': 'သင်၏ဂိမ်းကိုရွေးချယ်ပါ',
      'choose_category': 'အမျိုးအစားကိုရွေးချယ်ပါ',
      'game_statistics': 'ဂိမ်းစာရင်းအင်း',
      'edit_profile': 'ပရိုဖိုင်းကိုတည်းဖြတ်ပါ',
      'find': 'ရှာဖွေပါ',
      'requests': 'တောင်းဆိုချက်များ',
      'account_settings': 'အကောင့်ဆက်တင်များ',
      'not_available': 'မရနိုင်ပါ',

      'logout': 'ထွက်ရန်',
      'switch_player_mode': 'ကစားသမားမော်ဒ်ကိုပြောင်းရန်',
      'profile': 'ပရိုဖိုင်း',
      'shop': 'ဆိုင်',
      'settings': 'ဆက်တင်များ',
      'friends': 'သူငယ်ချင်းများ',
      'checking_authentication': 'အတည်ပြုမှုကိုစစ်ဆေးနေသည်...',
      'checking_connection': 'ချိတ်ဆက်မှုကိုစစ်ဆေးနေသည်...',
      // No Internet Screen
      'no_internet_connection': 'အင်တာနက်ချိတ်ဆက်မှုမရှိပါ',
      'check_connection_and_try_again':
          'သင်၏ချိတ်ဆက်မှုကိုစစ်ဆေးပြီး ထပ်မံကြိုးစားပါ။',
      'connection_required': 'ချိတ်ဆက်မှုလိုအပ်သည်',
      'connection_required_message':
          'Mindrena ကိုအသုံးပြုရန် အင်တာနက်ချိတ်ဆက်မှု လိုအပ်ပါသည်။ သင်၏ WiFi သို့မဟုတ် မိုဘိုင်းဒေတာကို စစ်ဆေးပါ။',
      'checking': 'စစ်ဆေးနေသည်...',
      'try_again': 'ထပ်ကြိုးစားပါ',
      'quick_tips': 'အကြံပြုချက်များ:',
      'tip_check_wifi': 'သင်၏ WiFi ချိတ်ဆက်မှုကို စစ်ဆေးပါ',
      'tip_switch_data': 'မိုဘိုင်းဒေတာသို့ ပြောင်းသုံးကြည့်ပါ',
      'tip_move_closer': 'သင်၏ router နှင့် ပိုနီးသောနေရာသို့ ရွှေ့ပါ',
      'tip_restart_device': 'လိုအပ်ပါက သင်၏စက်ကို ပြန်လည်စတင်ပါ',
      // Ad Dialog
      'cannot_open_website': 'ဝဘ်ဆိုဒ်ကိုဖွင့်မရပါ',
      'cannot_open_website_message':
          'အင်တာနက်ချိတ်ဆက်မှု သို့မဟုတ် အက်ပ်တွင် တစ်ခုခုမှားယွင်းနေသည်!',
      // User Guides
      'user_guides': 'အသုံးပြုသူလမ်းညွှန်များ',
      'how_can_we_help': 'ကျွန်ုပ်တို့ ဘယ်လိုကူညီပေးရမလဲ။',
      'find_answers_and_learn':
          'အဖြေများကိုရှာဖွေပြီး ကျွန်ုပ်တို့၏အက်ပ်ကို ထိရောက်စွာအသုံးပြုနည်းကို လေ့လာပါ။',
      'helpful_guides': 'အထောက်အကူဖြစ်စေသော လမ်းညွှန်များ',
      'helpful_guides_available': 'အထောက်အကူဖြစ်စေသော လမ်းညွှန်များ ရနိုင်သည်',
      'tap_to_explore': 'စူးစမ်းရန်နှိပ်ပါ',
      'no_guides_available': 'လမ်းညွှန်များမရှိပါ',
      'check_back_later_for_guides':
          'အထောက်အကူဖြစ်စေသော လမ်းညွှန်များနှင့် သင်ခန်းစာများအတွက် နောက်မှပြန်စစ်ဆေးပါ',
      'oops_something_went_wrong': 'အိုး! တစ်ခုခုမှားသွားသည်',
      'images': 'ပုံများ:',
      'image_not_available': 'ပုံမရနိုင်ပါ',
      'video_tutorial': 'ဗီဒီယိုသင်ခန်းစာ:',
      'watch_video_tutorial': 'ဗီဒီယိုသင်ခန်းစာကြည့်ရန်',
      'tap_to_open_in_browser': 'ဘရောက်ဇာတွင်ဖွင့်ရန်နှိပ်ပါ',
      'last_updated': 'နောက်ဆုံးမွမ်းမံမှု: @lastUpdated',

      // User Guide Categories
      'category_getting-started': 'စတင်အသုံးပြုခြင်း',
      'category_account': 'အကောင့်',
      'category_troubleshooting': 'ပြဿနာဖြေရှင်းခြင်း',
      'category_friends': 'သူငယ်ချင်းများ',
      'category_quizzes': 'ကစားပွဲများ',
      'category_general': 'အထွေထွေ',

      // Lobby
      'lobby': 'ဧည့်ခန်း',
      'waiting_for_friend_to_accept':
          '@friendName ၏ ဖိတ်ခေါ်မှုကို လက်ခံရန် စောင့်ဆိုင်းနေသည်...',
      'joining_friends_game': '@friendName ၏ ဂိမ်းသို့ဝင်ရောက်နေသည်...',
      'looking_for_another_player':
          '@category တွင် အခြားကစားသမားတစ်ဦးကို ရှာဖွေနေသည်...',
      'both_players_joined':
          'ကစားသမားနှစ်ဦးလုံးဝင်ရောက်ပြီးပါပြီ! စတင်ရန်အသင့်ပြင်ပါ!',
      'waiting_for_second_player':
          'ဒုတိယကစားသမားဝင်ရောက်ရန် စောင့်ဆိုင်းနေသည်...',
      'friend_invitation': 'သူငယ်ချင်းဖိတ်ခေါ်ခြင်း',
      'playing_with_friend': 'သူငယ်ချင်းနှင့်ကစားခြင်း',
      'random_match': 'ကျပန်းပွဲစဉ်',
      'player': 'ကစားသမား',
      'waiting': 'စောင့်ဆိုင်းနေသည်...',
      'you': 'သင်',
      'ready': 'အသင့်',
      'cancel_ready': 'အသင့်မဖြစ်သေး',
      'ready_to_start': 'စတင်ရန်အသင့်!',
      'leave_lobby_q': 'ဧည့်ခန်းမှထွက်ခွာမည်လား?',
      'another_player_is_waiting':
          'အခြားကစားသမားတစ်ဦး စောင့်ဆိုင်းနေပါသည်။ သင်ထွက်ခွာလိုသည်မှာ သေချာပါသလား။',
      'are_you_sure_leave_lobby': 'ဧည့်ခန်းမှထွက်ခွာလိုသည်မှာ သေချာပါသလား။',
      'stay': 'နေမည်',
      'leave': 'ထွက်မည်',
      'leave_lobby': 'ဧည့်ခန်းမှထွက်ခွာရန်',

      // Single Player Quiz
      'score': 'အမှတ်: @score',
      'question_of': 'မေးခွန်း @current / @total',
      'loading_question': 'မေးခွန်းတင်နေသည်...',
      'quiz_summary':
          'မေးခွန်း @total ခုအနက် @score ခု မှန်ကန်စွာဖြေဆိုနိုင်ခဲ့သည်။',
      'quiz_results_summary':
          'မေးခွန်း @total ခုအနက် @score ခု မှန်ကန်စွာဖြေဆိုနိုင်ခဲ့သည်။',
      'play_again': 'ထပ်ကစားမည်',
      'exit_game': 'ဂိမ်းမှထွက်မည်',
      'your_answer': 'သင်၏အဖြေ: @answer',
      'correct_answer': 'အဖြေမှန်: @answer',
      'your_aswer': 'သင်၏အဖြေ: @answer', // To handle potential typo
      // Sign In & Feedback
      'welcome_back': 'ပြန်လည်ကြိုဆိုပါသည်!',
      'signed_in_successfully': 'အောင်မြင်စွာဝင်ရောက်ပြီးပါပြီ',
      'error': 'အမှား',
      'failed_to_save_user_data':
          'အသုံးပြုသူဒေတာသိမ်းဆည်းရန်မအောင်မြင်ပါ: @error',
      'failed_to_sign_in_google': 'Google ဖြင့်ဝင်ရောက်ရန်မအောင်မြင်ပါ',
      'google_sign_in_failed': 'Google ဖြင့်ဝင်ရောက်ရန်မအောင်မြင်ပါ',
      'google_sign_in_error': 'Google ဖြင့်ဝင်ရောက်မှုအမှား: @error',
      'please_enter_email': 'သင်၏အီးမေးလ်ကိုထည့်ပါ',
      'please_enter_valid_email': 'မှန်ကန်သောအီးမေးလ်လိပ်စာထည့်ပါ',
      'please_enter_password': 'သင်၏စကားဝှက်ကိုထည့်ပါ',
      'password_min_length': 'စကားဝှက်သည် အနည်းဆုံး စာလုံး ၆ လုံးရှိရမည်',

      // User Guides Controller
      'error_fetching_guides': 'လမ်းညွှန်များရယူရာတွင်အမှား: @error',

      // Settings
      'settings': 'ဆက်တင်များ',
      'game_settings': 'ဂိမ်းဆက်တင်များ',
      'support': 'အကူအညီ',
      'about': 'အကြောင်း',
      'language': 'ဘာသာစကား',
      'choose_language': 'သင်နှစ်သက်သော ဘာသာစကားကို ရွေးချယ်ပါ',
      'english': 'အင်္ဂလိပ်',
      'myanmar': 'မြန်မာ',
      'sound_effects': 'အသံထွက်များ',
      'enable_disable_sound': 'အသံထွက်များကို ဖွင့်/ပိတ်ပါ',
      'notifications': 'အသိပေးချက်များ',
      'receive_updates': 'ဂိမ်းအပ်ဒိတ်များနှင့် စိန်ခေါ်မှုများကို လက်ခံရယူပါ',
      'notifications_enabled': 'အသိပေးချက်များ ဖွင့်ထားသည်',
      'notifications_disabled': 'အသိပေးချက်များ ပိတ်ထားသည်',
      'user_guide': 'အသုံးပြုသူလမ်းညွှန်',
      'get_help': 'အကူအညီရယူပြီး အဖြေများရှာပါ',
      'send_feedback': 'အကြံပြုချက်ပို့ရန်',
      'share_your_thoughts': 'သင်၏အတွေးအမြင်များကို မျှဝေပါ',
      'rate_app': 'အက်ပ်ကို အဆင့်သတ်မှတ်ပါ',
      'rate_us_on_store': 'App Store တွင် ကျွန်ုပ်တို့ကို အဆင့်သတ်မှတ်ပါ',
      'thank_you_for_support': 'သင်၏ ပံ့ပိုးမှုအတွက် ကျေးဇူးတင်ပါသည်!',
      'version': 'ဗားရှင်း',
      'privacy_policy': 'ကိုယ်ရေးကိုယ်တာ မူဝါဒ',
      'read_privacy_policy': 'ကျွန်ုပ်တို့၏ ကိုယ်ရေးကိုယ်တာ မူဝါဒကို ဖတ်ရှုပါ',
      'privacy_policy_soon': 'ကိုယ်ရေးကိုယ်တာ မူဝါဒ မကြာမီလာမည်!',
      'terms_of_service': 'ဝန်ဆောင်မှုစည်းမျဉ်းများ',
      'read_terms_of_service':
          'ကျွန်ုပ်တို့၏ ဝန်ဆောင်မှုစည်းမျဉ်းများကို ဖတ်ရှုပါ',
      'terms_of_service_soon': 'ဝန်ဆောင်မှုစည်းမျဉ်းများ မကြာမီလာမည်!',
      'all_rights_reserved': '© @year Mindrena. မူပိုင်ခွင့်များရယူပြီး။',

      // User Feedback
      'feedback_performance': 'စွမ်းဆောင်ရည်',
      'feedback_bug_report': 'Bug အစီရင်ခံစာ',
      'feedback_feature_request': 'Feature တောင်းဆိုချက်',
      'feedback_ui_ux': 'UI/UX',
      'feedback_product_quality': 'ကုန်ပစ္စည်းအရည်အသွေး',
      'feedback_delivery_service': 'ပို့ဆောင်ရေးဝန်ဆောင်မှု',
      'feedback_customer_support': 'သုံးစွဲသူအကူအညီ',
      'feedback_other': 'အခြား',
      'please_login_to_submit':
          'အကြံပြုချက်ပေးပို့ရန် ကျေးဇူးပြု၍ လော့ဂ်အင်ဝင်ပါ',
      'anonymous_user': 'အမည်မသိအသုံးပြုသူ',
      'feedback_success_title': 'အောင်မြင်သည်',
      'feedback_success_message':
          'အကြံပြုချက်ကို အောင်မြင်စွာ ပေးပို့ပြီးပါပြီ!',
      'feedback_error_title': 'အမှား',
      'feedback_error_message': 'အကြံပြုချက်ပေးပို့ရန် မအောင်မြင်ပါ: @error',
      'enter_feedback_title': 'သင်၏အကြံပြုချက်အတွက် ခေါင်းစဉ်တစ်ခုထည့်ပါ',
      'enter_feedback_message': 'သင်၏အကြံပြုချက်စာကို ထည့်ပါ',
      'title_min_length': 'ခေါင်းစဉ်သည် အနည်းဆုံး စာလုံး ၃ လုံးရှိရမည်',
      'message_min_length': 'အကြံပြုချက်စာသည် အနည်းဆုံး စာလုံး ၆ လုံးရှိရမည်',
      'feedback_deleted_success': 'အကြံပြုချက်ကို အောင်မြင်စွာ ဖျက်လိုက်ပါပြီ',
      'feedback_deleted_error': 'အကြံပြုချက်ဖျက်ရန် မအောင်မြင်ပါ: @error',

      // Feedback Model
      'feedback_type_product': 'ကုန်ပစ္စည်းသုံးသပ်ချက်',
      'feedback_type_service': 'ဝန်ဆောင်မှုအကြံပြုချက်',
      'feedback_type_delivery': 'ပို့ဆောင်ရေးအကြံပြုချက်',
      'feedback_type_app': 'အက်ပ်အကြံပြုချက်',
      'feedback_type_general': 'အထွေထွေအကြံပြုချက်',
      'feedback_type_default': 'အကြံပြုချက်',
      'feedback_status_pending': 'သုံးသပ်ရန်စောင့်ဆိုင်းနေသည်',
      'feedback_status_reviewed': 'သုံးသပ်ပြီး',
      'feedback_status_resolved': 'ဖြေရှင်းပြီး',
      'feedback_status_rejected': 'ပယ်ချသည်',
      'feedback_status_unknown': 'မသိပါ',

      // Profile
      'sign_out_error': 'ထွက်ရန်မအောင်မြင်ပါ: @error',

      // Auth Service Errors
      'auth_error_google_canceled': 'ဝင်ရောက်ခြင်းကို ပယ်ဖျက်လိုက်သည်',
      'auth_error_google_interrupted': 'ဝင်ရောက်ခြင်းကို နှောင့်ယှက်ခဲ့သည်',
      'auth_error_google_client_config':
          'Google ဝင်ရောက်ခြင်း ဖွဲ့စည်းပုံ အမှား',
      'auth_error_google_provider_config': 'ဝန်ဆောင်မှုပေးသူ ဖွဲ့စည်းပုံ အမှား',
      'auth_error_google_ui_unavailable': 'ဝင်ရောက်ရန် UI မရနိုင်ပါ',
      'auth_error_google_user_mismatch': 'အသုံးပြုသူ မကိုက်ညီမှု အမှား',
      'auth_error_google_unknown': 'မသိသော Google ဝင်ရောက်ခြင်း အမှား',
      'auth_error_firebase_diff_credential':
          'အခြားဝင်ရောက်နည်းလမ်းဖြင့် အကောင့်တစ်ခု ရှိနှင့်ပြီးသားဖြစ်သည်။',
      'auth_error_firebase_invalid_credential':
          'အထောက်အထားသည် မမှန်ကန်ပါ သို့မဟုတ် သက်တမ်းကုန်သွားပြီ။',
      'auth_error_firebase_op_not_allowed':
          'Google ဝင်ရောက်ခြင်းကို ဖွင့်မထားပါ။',
      'auth_error_firebase_user_disabled': 'ဤအသုံးပြုသူအကောင့်ကို ပိတ်ထားသည်။',
      'auth_error_firebase_user_not_found':
          'ဤအထောက်အထားဖြင့် အသုံးပြုသူကို ရှာမတွေ့ပါ။',
      'auth_error_firebase_wrong_password': 'မမှန်ကန်သော စကားဝှက်။',
      'auth_error_firebase_invalid_code': 'မမှန်ကန်သော အတည်ပြုကုဒ်။',
      'auth_error_firebase_invalid_id': 'မမှန်ကန်သော အတည်ပြု ID။',
      'auth_error_firebase_generic': 'အတည်ပြုခြင်း အမှား (@code): @message',
      'auth_error_google_no_token': 'Google ID တိုကင်ရယူရန် မအောင်မြင်ပါ',
      'auth_error_unexpected_signin':
          'Google ဝင်ရောက်စဉ် မမျှော်လင့်သော အမှား: @error',
      'auth_error_no_google_user': 'Google အသုံးပြုသူ ဝင်ရောက်မထားပါ',
      'auth_error_scope_request':
          'ခွင့်ပြုချက်များ တောင်းဆိုရာတွင် အမှား: @error',
      'auth_error_server_auth_code':
          'ဆာဗာ အထောက်အထားကုဒ် ရယူရာတွင် အမှား: @error',
      'auth_error_auth_headers':
          'ခွင့်ပြုချက် ခေါင်းစဉ်များ ရယူရာတွင် အမှား: @error',
      'auth_error_signout': 'ထွက်ခွာစဉ် အမှား: @error',
      'auth_error_disconnect': 'ချိတ်ဆက်မှုဖြတ်တောက်စဉ် အမှား: @error',

      // Sign In Controller
      'google_user_fallback': 'Google အသုံးပြုသူ',

      // Question Model
      'not_available': 'မရနိုင်ပါ',
    },
    'th_TH': {
      // Placeholder for future Thai translations
    },
  };
}
