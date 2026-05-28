import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../chat/controllers/chat_controller.dart';

class MainController extends GetxController {

  final RxInt currentIndex = 0.obs;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onInit() {
    super.onInit();
    Get.put(ChatController());
    
    // Tự động nhận chỉ số tab được truyền vào từ màn hình khác
    if (Get.arguments != null && Get.arguments is int) {
      currentIndex.value = Get.arguments as int;
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}