import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../history/controllers/history_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/guest_upgrade_banner.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_stats_card.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    // Truy xuất ProfileController
    final ProfileController profileController = Get.find<ProfileController>();

    // Truy xuất HistoryController để lấy số lượt chẩn đoán
    final HistoryController historyController = Get.find<HistoryController>();

    void handleSignOut() async {
      Get.defaultDialog(
        title: 'Xác nhận',
        middleText: 'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
        textConfirm: 'Đăng xuất',
        textCancel: 'Hủy',
        confirmTextColor: Colors.white,
        buttonColor: AppColors.error,
        onConfirm: () async {
          Get.back(); // Đóng hộp thoại
          await authController.signOut();
          Get.offAllNamed(Routes.LOGIN);
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ Cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(
        () => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. PHẦN AVATAR VÀ TIÊU ĐỀ HỌ TÊN CHỦ ĐẠO (HEADER GRADIENT)
              const ProfileHeader(),
              const SizedBox(height: AppSizes.p24),

              // 2. PHẦN DỮ LIỆU CHI TIẾT VÀ CÁC THAO TÁC TÀI KHOẢN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CARD THỐNG KÊ TỔNG LƯỢT KHÁM
                    const ProfileStatsCard(),
                    const SizedBox(height: AppSizes.p24),

                    // CÁC DÒNG HIỂN THỊ THÔNG TIN CHI TIẾT
                    const ProfileInfoSection(),
                    const SizedBox(height: AppSizes.p24),

                    // CẢNH BÁO BÊN DƯỚI DÀNH CHO TÀI KHOẢN GUEST
                    if (authController.isGuest) ...[
                      const GuestUpgradeBanner(),
                      const SizedBox(height: AppSizes.p24),
                    ],

                    // NÚT CHỈNH SỬA HỒ SƠ (CHỈ CÓ KHI KHÔNG PHẢI LÀ GUEST)
                    if (!authController.isGuest) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.bottomSheet(
                              const EditProfileSheet(),
                              isScrollControlled: true,
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Chỉnh sửa Hồ sơ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            ),
                            elevation: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p16),
                    ],

                    // NÚT ĐĂNG XUẤT AN TOÀN
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: handleSignOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(
                          authController.isGuest ? 'Đăng xuất khỏi tài khoản Khách' : 'Đăng xuất tài khoản',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
