import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startNavigationDelay();
  }

  void _startNavigationDelay() async {
    // Độ trễ 2.5 giây đủ để hiển thị trọn vẹn hiệu ứng animation cao cấp
    await Future.delayed(const Duration(milliseconds: 2500));

    final isFirstTime = GetStorage().read('isFirstTime') ?? true;
    if (isFirstTime) {
      Get.offAllNamed(Routes.ONBOARDING);
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    Get.offAllNamed(Routes.MAIN);
  }
}
