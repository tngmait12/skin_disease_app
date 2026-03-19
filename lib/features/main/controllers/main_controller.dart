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
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}