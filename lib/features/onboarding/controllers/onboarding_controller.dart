import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../main/screens/main_screen.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  final pageController = PageController();
  final box = GetStorage();


  void nextPage() {
    if (currentPage.value == 2) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }


  void onPageChanged(int index) {
    currentPage.value = index;
  }


  void finishOnboarding() {
    box.write('isFirstTime', false);
    Get.offAll(() => const MainScreen());
  }
}