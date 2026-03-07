import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../main/screens/main_screen.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  final pageController = PageController();
  final box = GetStorage();

  // Chuyển sang trang tiếp theo
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

  // Cập nhật index khi người dùng vuốt tay
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  // Hoàn thành Onboarding, lưu trạng thái và chuyển vào màn hình chính
  void finishOnboarding() {
    box.write('isFirstTime', false); // Lưu cờ đánh dấu đã xem
    Get.offAll(() => const MainScreen()); // Xóa lịch sử điều hướng và vào app
  }
}