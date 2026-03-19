import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/features/chat/screens/chat_screen.dart';
import 'package:skin_disease_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:skin_disease_app/features/history/screens/history_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_drawer.dart';
import '../../home/screens/home_screen.dart';
import '../controllers/main_controller.dart';

class MainScreen extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final List<Widget> screens = [
    HomeScreen(),
    HistoryScreen(),
    DashboardScreen(),
    ChatScreen(),
  ];

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: CustomDrawer(),
      body: Obx(
            () => IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,

          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          type: BottomNavigationBarType.fixed,
          elevation: 8,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'Lịch sử',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph_outlined),
              activeIcon: Icon(Icons.auto_graph_rounded),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI Assistant',
            ),
          ],
        ),
      ),
    );
  }
}