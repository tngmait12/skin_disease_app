import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ProfileController profileController = Get.find<ProfileController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin chi tiết',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSizes.p12),

        // CÁC DÒNG HIỂN THỊ THÔNG TIN CHI TIẾT (REACT STREAM)
        Obx(() {
          final profile = profileController.userProfile.value;
          final isGuest = authController.isGuest;
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.person_rounded,
                  title: 'Họ và tên',
                  subtitle: isGuest
                      ? 'Khách hàng ẩn danh'
                      : (profile?.fullName ?? 'Thành viên SkinShield'),
                  isLocked: isGuest,
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Số điện thoại',
                  subtitle: isGuest
                      ? 'Chưa cập nhật'
                      : (profile?.phoneNumber.isNotEmpty == true
                          ? profile!.phoneNumber
                          : 'Chưa thiết lập (Bấm Chỉnh sửa để thêm)'),
                  isLocked: isGuest,
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.cake_rounded,
                  title: 'Ngày sinh',
                  subtitle: isGuest
                      ? 'Chưa cập nhật'
                      : (profile?.dob.isNotEmpty == true
                          ? _formatDob(profile!.dob)
                          : 'Chưa thiết lập (Bấm Chỉnh sửa để thêm)'),
                  isLocked: isGuest,
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.wc_rounded,
                  title: 'Giới tính',
                  subtitle: isGuest
                      ? 'Chưa cập nhật'
                      : (profile?.gender ?? 'Chưa xác định'),
                  isLocked: isGuest,
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.alternate_email_rounded,
                  title: 'Địa chỉ Email',
                  subtitle: authController.userEmail,
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Mã người dùng (UID)',
                  subtitle: authController.currentUserId.value,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Chuyển ngày sinh định dạng yyyy-MM-dd thành dd/MM/yyyy hiển thị cho thân thiện
  String _formatDob(String dob) {
    if (dob.isEmpty) return 'Chưa thiết lập';
    try {
      final parts = dob.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (_) {}
    return dob;
  }

  // Khung chứa các dòng hiển thị thông tin
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLocked = false,
  }) {
    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        trailing: isLocked
            ? const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 16)
            : null,
      ),
    );
  }
}
