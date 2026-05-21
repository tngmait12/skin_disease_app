import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: AppSizes.p32, top: AppSizes.p16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXLarge),
          bottomRight: Radius.circular(AppSizes.radiusXLarge),
        ),
      ),
      child: Column(
        children: [
          // Avatar tròn với hiệu ứng viền nổi bật
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[100],
              child: Icon(
                authController.isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          
          // Hiển thị Họ Tên người dùng reactive theo Firestore
          Obx(() {
            final profile = profileController.userProfile.value;
            return Text(
              authController.isGuest
                  ? 'Người dùng Khách (Guest)'
                  : (profile?.fullName ?? 'Thành viên SkinShield'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
          const SizedBox(height: AppSizes.p8),
          
          // Loại tài khoản Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              authController.isGuest ? 'Tài khoản khách ẩn danh' : 'Tài khoản Email bảo mật',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
