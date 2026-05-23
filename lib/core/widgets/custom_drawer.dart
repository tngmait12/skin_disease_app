import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/features/dashboard/controllers/dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/controllers/profile_controller.dart';
import '../../features/main/controllers/main_controller.dart';
import '../../routes/app_routes.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.find<ProfileController>();
    
    // Tìm hoặc khởi tạo DashboardController an toàn
    final String diseaseName = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>().latestDisease.value
        : 'Melanoma';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 1. PHẦN HEADER PREMIUM (Thông tin User Tùy chỉnh)
          Obx(() {
            final isGuest = authController.isGuest;
            final profile = profileController.userProfile.value;
            
            // Lấy Họ tên thực tế hoặc fallback
            final String displayName = isGuest 
                ? 'Người dùng Khách' 
                : (profile?.fullName != null && profile!.fullName.isNotEmpty 
                    ? profile.fullName 
                    : 'Thành viên SkinShield');
                
            final String displayInfo = isGuest
                ? 'ID: ${authController.currentUserId.value.length > 8 ? "${authController.currentUserId.value.substring(0, 8)}..." : authController.currentUserId.value}'
                : (profile?.email ?? authController.userEmail);

            // Chữ cái viết tắt làm Avatar
            String initials = 'G';
            if (!isGuest && displayName.isNotEmpty) {
              final words = displayName.trim().split(' ');
              if (words.length >= 2) {
                initials = '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
              } else if (words.isNotEmpty && words[0].isNotEmpty) {
                initials = words[0][0].toUpperCase();
              }
            } else if (!isGuest) {
              initials = 'S';
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    Color(0xFF0077B6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar vòng tròn cách điệu
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      // Badge loại tài khoản
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Text(
                          isGuest ? 'GUEST' : 'MEMBER',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayInfo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),

          // 2. DANH SÁCH CÁC CHỨC NĂNG
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Hồ sơ cá nhân',
                  onTap: () {
                    Get.back(); // Đóng drawer
                    Get.toNamed(Routes.PROFILE);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Lịch sử khám toàn diện',
                  onTap: () {
                    Get.back(); // Đóng drawer
                    Get.find<MainController>().changeTab(1); // Chuyển sang Tab Lịch sử
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.spa_outlined,
                  title: 'Skincare Routine',
                  onTap: () {
                    Get.back(); // Đóng drawer
                    Get.toNamed(Routes.ROUTINE, arguments: diseaseName);
                  },
                ),
                const Divider(), // Đường kẻ ngang phân cách
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Hướng dẫn sử dụng',
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      'Hướng dẫn',
                      'Vui lòng chọn ảnh từ Gallery hoặc dùng Camera chụp vùng da bị tổn thương để nhận diện.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. NÚT ĐĂNG XUẤT / ĐĂNG NHẬP Ở ĐÁY DRAWER
          const Divider(height: 1),
          Obx(() {
            final bool isGuest = authController.isGuest;
            return ListTile(
              leading: Icon(
                isGuest ? Icons.login_rounded : Icons.logout_rounded,
                color: isGuest ? AppColors.primary : AppColors.error,
              ),
              title: Text(
                isGuest ? 'Đăng nhập / Đăng ký' : 'Đăng xuất tài khoản',
                style: TextStyle(
                  color: isGuest ? AppColors.primary : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back(); // Đóng drawer
                if (isGuest) {
                  Get.offAllNamed(Routes.LOGIN);
                } else {
                  Get.defaultDialog(
                    title: 'Xác nhận',
                    middleText: 'Bạn có chắc chắn muốn đăng xuất không?',
                    textConfirm: 'Đăng xuất',
                    textCancel: 'Hủy',
                    confirmTextColor: Colors.white,
                    buttonColor: AppColors.error,
                    onConfirm: () async {
                      Get.back();
                      await authController.signOut();
                      Get.offAllNamed(Routes.LOGIN);
                    },
                  );
                }
              },
            );
          }),
          const SizedBox(height: 20), // Cách đáy một chút cho đẹp
        ],
      ),
    );
  }

  // Hàm hỗ trợ vẽ từng nút bấm trong Menu cho gọn code
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}