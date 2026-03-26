import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/features/dashboard/controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/main/controllers/main_controller.dart';
import '../../features/routine/screens/routine_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context){
    var userID = Get.find<AuthController>().currentUserId.value;
    var diseaseName = Get.find<DashboardController>().latestDisease.value;
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. PHẦN HEADER (Thông tin User)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              // Thêm ảnh nền mờ ảo cho xịn (Nều có ảnh mạng, không thì dùng màu trơn)
              // image: DecorationImage(image: NetworkImage('...'), fit: BoxFit.cover),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(Icons.person, size: 40, color: AppColors.primary),
            ),
            accountName: const Text(
                'Người dùng Hệ thống',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            // Lấy ID thiết bị hoặc Email nếu bạn có lưu trong Controller
            accountEmail: Text('ID: $userID'),
          ),

          // 2. DANH SÁCH CÁC CHỨC NĂNG
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Hồ sơ cá nhân',
                  onTap: () {
                    Get.back();
                    // Get.to(() => const ProfileScreen());
                    Get.snackbar('Thông báo', 'Chức năng đang phát triển');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Lịch sử khám toàn diện',
                  onTap: () {
                    Get.find<MainController>().changeTab(1);
                    Get.back();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.spa_outlined,
                  title: 'Routine',
                  onTap: () {
                    Get.to(() => RoutineScreen(diseaseName: diseaseName)); // Hoặc thử truyền chữ 'Melanoma'
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt ứng dụng',
                  onTap: () {
                    Get.to(() => const RoutineScreen(diseaseName: 'Melanoma')); // Hoặc thử truyền chữ 'Melanoma'
                  },
                ),
                const Divider(), // Đường kẻ ngang phân cách
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Hướng dẫn sử dụng',
                  onTap: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ),

          // 3. NÚT ĐĂNG XUẤT (Nằm bám đáy màn hình)
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Đăng xuất / Xóa dữ liệu', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () {
              Get.back(); // Đóng menu
              // Gọi hàm cảnh báo xóa dữ liệu hoặc đăng xuất ở đây
            },
          ),
          const SizedBox(height: 20), // Cách đáy một chút cho đẹp
        ],
      ),
    );
  }

// Hàm hỗ trợ vẽ từng nút bấm trong Menu cho gọn code
  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}