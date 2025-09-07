import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthGateController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();
  RxBool hasInternet = true.obs; // Observable for internet connection status
  var isLoading = false.obs;
  String mode = Get.arguments ?? 'single'; // Default to 'single' if no argument
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  void onInit() async {
    super.onInit();

    // Listen for connectivity changes using the connectivity_plus stream
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // Check if the list contains any active network connection type
      if (results.contains(ConnectivityResult.none)) {
        hasInternet.value = false;
        Get.offAllNamed('/no-internet');
        isLoading.value = false;
      } else {
        hasInternet.value = true;
        _checkAuthentication();
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    isLoading.value = true; // Start loading
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      hasInternet.value = false;
      Get.offAllNamed('/no-internet');
    } else {
      hasInternet.value = true;
      _checkAuthentication();
    }
    isLoading.value = false; // Stop loading after the check
  }

  void _checkAuthentication() {
    isLoading.value = true; // Show loading while checking authentication
    authStateChanges.listen((User? user) {
      if (user == null) {
        Get.offAllNamed('/sign-in', arguments: mode);
        isLoading.value = false;
      } else {
        String userId = user.uid;
        DocumentReference userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);

        userDocRef
            .get()
            .then((DocumentSnapshot userDoc) {
              if (userDoc.exists) {
                Map<String, dynamic>? userData =
                    userDoc.data() as Map<String, dynamic>?;
                if (userData != null) {
                  if (mode == 'single') {
                    Get.offAllNamed('/single-player');
                  } else {
                    Get.offAllNamed('/home');
                  }
                }
              } else {
                print('User document does not exist');
                Get.offAllNamed('/sign-in');
              }
            })
            .catchError((error) {
              print('Error getting user document: $error');
            });
      }
    });
  }

  void retryConnection() {
    _checkInternetConnection();
  }
}
