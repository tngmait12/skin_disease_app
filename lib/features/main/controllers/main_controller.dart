import 'package:get/get.dart';

import '../../chat/controllers/chat_controller.dart';

class MainController extends GetxController {

  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(ChatController());
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}