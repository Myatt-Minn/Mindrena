import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/populate_data_functions.dart';
import 'package:mindrena/app/data/userGuideModel.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class UserGuidesController extends GetxController {
  var userGuides = <UserGuideCategoryModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedCategory = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    // You can switch between fetchUserGuides() and populateSampleUserGuides()
    // Use populateSampleUserGuides() for testing without Firebase
    // Use fetchUserGuides() for production with Firebase data
    fetchUserGuides(); // Change to populateSampleUserGuides() for sample data
  }

  // Fetch user guides from Firebase with proper join
  Future<void> fetchUserGuides() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // First, fetch all user guides
      final guidesSnapshot = await FirebaseFirestore.instance
          .collection('user_guides')
          .get();

      userGuides.clear();

      // For each guide, fetch its related guide items
      for (var guideDoc in guidesSnapshot.docs) {
        final guideData = guideDoc.data();
        final guideId = guideDoc.id;

        // Fetch guide items for this specific guide
        final guideItemsSnapshot = await FirebaseFirestore.instance
            .collection('guide_items')
            .where('user_guide_id', isEqualTo: guideId)
            .get();

        // Transform guide items data
        final List<Map<String, dynamic>> items = [];
        int itemId = 1;
        for (var itemDoc in guideItemsSnapshot.docs) {
          final itemData = itemDoc.data();
          items.add({
            'id': itemId++,
            'guide_id': int.tryParse(guideId) ?? 0,
            'title': itemData['title'] ?? '',
            'description': itemData['description'] ?? '',
            'content': itemData['content'] ?? '',
            'images': itemData['images'] ?? [],
            'video_url': itemData['video_url'] ?? '',
            'last_updated': itemData['last_updated'] ?? '',
          });
        }

        // Create the complete guide data structure
        final completeGuideData = {
          'id': int.tryParse(guideId) ?? 0,
          'title': guideData['title'] ?? '',
          'items': items,
        };

        userGuides.add(UserGuideCategoryModel.fromJson(completeGuideData));
      }

      print('Fetched ${userGuides.length} user guides with their items');
    } catch (e) {
      errorMessage.value = 'Error fetching guides: $e';
      print('Error fetching user guides: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get filtered guides
  List<UserGuideCategoryModel> get filteredGuides {
    if (selectedCategory.value == 'all') {
      return userGuides.toList();
    }
    return userGuides
        .where((guide) => guide.title == selectedCategory.value)
        .toList();
  }

  // Set category filter
  void setCategory(String category) {
    selectedCategory.value = category;
  }

  // Refresh guides
  Future<void> refreshGuides() async {
    await fetchUserGuides();
  }

  // Load sample data for testing
  Future<void> loadSampleData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Call the populate function from the global file
      await populateSampleUserGuides();

      // Then fetch the populated data
      await fetchUserGuides();
    } catch (e) {
      errorMessage.value = 'Error loading sample data: $e';
      print('Error loading sample data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Switch between sample and Firebase data
  Future<void> switchDataSource({bool useSampleData = false}) async {
    if (useSampleData) {
      await loadSampleData();
    } else {
      await fetchUserGuides();
    }
  }

  void goToWebsite(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      QuickAlert.show(
        context: Get.context!,
        type: QuickAlertType.error,
        title: 'Cannot open the website',
        text: 'Something wrong with Internet Connection or the app!',
      );
    }
  }
}
