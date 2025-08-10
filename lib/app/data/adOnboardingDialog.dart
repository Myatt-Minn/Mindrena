import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindrena/app/data/AdDataModel.dart';
import 'package:mindrena/app/modules/f_category_selection/controllers/f_category_selection_controller.dart';
import 'package:mindrena/app/modules/m_category_selection/controllers/m_category_selection_controller.dart';
import 'package:mindrena/app/modules/s_category_selection/controllers/s_category_selection_controller.dart';
import 'package:mindrena/app/modules/shop/controllers/shop_controller.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class AdOnboardingDialog extends StatefulWidget {
  final List<AdData> ads;
  final VoidCallback? onComplete;

  const AdOnboardingDialog({super.key, required this.ads, this.onComplete});

  @override
  State<AdOnboardingDialog> createState() => _AdOnboardingDialogState();
}

class _AdOnboardingDialogState extends State<AdOnboardingDialog> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    Get.back();
    if (widget.onComplete != null) {
      widget.onComplete!();
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

  void _onAdTap(AdData ad) {
    // Handle ad tap (navigate to product, category, etc.)
    if (ad.actionType == 'shop' && ad.actionValue.isNotEmpty) {
      Get.back(); // Close dialog
      Get.put(ShopController());
      Get.toNamed('/shop');
    } else if (ad.actionValue == 'm-category' && ad.actionValue.isNotEmpty) {
      Get.back(); // Close dialog
      Get.put(MCategorySelectionController());
      Get.toNamed('/m-category-selection');
    } else if (ad.actionValue == 'f-category' && ad.actionValue.isNotEmpty) {
      Get.back(); // Close dialog
      Get.put(FCategorySelectionController());
      Get.toNamed('/f-category-selection');
    } else if (ad.actionValue == 's-category' && ad.actionValue.isNotEmpty) {
      Get.back(); // Close dialog
      Get.put(SCategorySelectionController());
      Get.toNamed('/s-category-selection');
    } else if (ad.actionType == 'url' && ad.actionValue.isNotEmpty) {
      goToWebsite(ad.actionValue);
    }
    _closeDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Stack(
          children: [
            // Page View (Full Screen)
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                // Page changed - no need to track current page
              },
              itemCount: widget.ads.length,
              itemBuilder: (context, index) {
                final ad = widget.ads[index];
                return _buildAdPage(ad);
              },
            ),

            // Close Button - Positioned over the image
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: _closeDialog,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),

            // Page Indicator - Positioned over the image at bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: widget.ads.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.5),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdPage(AdData ad) {
    return GestureDetector(
      onTap: () => _onAdTap(ad),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FancyShimmerImage(
            imageUrl: ad.imageUrl,
            boxFit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
