import 'package:eat_right/data/repositories/authentication_repo/authentication_repository.dart';
import 'package:eat_right/data/services/logic/new_logic/user_controller.dart';
import 'package:eat_right/navigation_menu.dart';
import 'package:eat_right/utils/constants/lottie_Str.dart';
import 'package:eat_right/utils/loaders/loaders.dart';
import 'package:eat_right/utils/network_manager/network_manager.dart';
import 'package:eat_right/utils/popups/full_screen_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class loginController extends GetxController {
  // Add your logic here

  static loginController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // update current index when page scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  void dotNavigationClick(index) {
    // jump to specific dot selected
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  void skipPage() {
    // skip to last page and move to home page
    currentPageIndex.value = 2;
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  Future<void> googleSignIn() async {
    // auth with google
    try {
      SFullScreenLoader.openLoadingDialog('Logging you in :)', Slottie.loading);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        SFullScreenLoader.stopLoading();
        return;
      }

      // google authentication
      final UserCredentials = await AuthenticationRepository.instance
          .signInWithGoogle();
      //  save user data
      await UserController.instance.handleUserAuth(UserCredentials);

      SFullScreenLoader.stopLoading();

      // redirect
      Get.offAll(() => const NavigationMenu());
    } catch (e) {
      SFullScreenLoader.stopLoading();
      SLoader.errorSnackBar(title: 'oh snap', message: e.toString());
    }
  }

  void nextPage() {
    // move to next page
    if (currentPageIndex.value == 2) {
      final deviceStorage = GetStorage();
      deviceStorage.write('IsFirstTime', false);
      // Get.to(LoginScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }
}
