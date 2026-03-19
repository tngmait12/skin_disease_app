import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/main/controllers/main_controller.dart';

class AppBarWithDrawer extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final List<Widget>? actions;

  const AppBarWithDrawer({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          Get.find<MainController>().scaffoldKey.currentState?.openDrawer();
        },
      ),

      title: Text(title),
      actions: actions,
      centerTitle: true,
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}