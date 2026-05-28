import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_app/core/models/scan_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/routine_model.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../controllers/history_detail_controller.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ScanModel item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final double confidenceValue = item.confidence;
    final String displayConfidence = confidenceValue.toStringAsFixed(2);
    Color statusColor = confidenceValue >= 80
        ? AppColors.success
        : (confidenceValue >= 50 ? AppColors.warning : AppColors.error);

    final HistoryDetailController aiController =
        Get.put(HistoryDetailController(diseaseName: item.diseaseName));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chẩn đoán'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Xuất Báo cáo PDF',
            onPressed: () {
              // Lấy đúng phác đồ tương ứng với tên bệnh
              final routine = getRoutineForDisease(
                  item.diseaseName); // Hàm lấy từ routine_model.dart

              // Lấy thông tin tài khoản và profile người dùng từ controllers ở tầng UI
              final profileController = Get.isRegistered<ProfileController>()
                  ? Get.find<ProfileController>()
                  : Get.put(ProfileController());
              final authController = Get.find<AuthController>();

              final profile = profileController.userProfile.value;
              final isGuest = authController.isGuest;

              final String fullName = isGuest
                  ? 'Người dùng Khách'
                  : (profile?.fullName != null && profile!.fullName.isNotEmpty
                      ? profile.fullName
                      : 'Thành viên SkinShield');
              final String email = isGuest
                  ? 'Khách ẩn danh'
                  : (profile?.email != null && profile!.email.isNotEmpty
                      ? profile.email
                      : authController.userEmail);
              final String phoneNumber = isGuest
                  ? 'Chưa thiết lập'
                  : (profile?.phoneNumber != null &&
                          profile!.phoneNumber.isNotEmpty
                      ? profile.phoneNumber
                      : 'Chưa thiết lập');
              final String dob = isGuest
                  ? 'Chưa thiết lập'
                  : (profile?.dob != null && profile!.dob.isNotEmpty
                      ? profile.dob
                      : 'Chưa thiết lập');
              final String gender = isGuest
                  ? 'Chưa thiết lập'
                  : (profile?.gender ?? 'Chưa xác định');
              final String uid = authController.currentUserId.value;

              // Gọi "Cỗ máy in" hoạt động!
              PdfExportService.generateAndPreviewReport(
                scan: item, // Biến ScanModel hiện tại của màn hình
                routine: routine,
                fullName: fullName,
                email: email,
                phoneNumber: phoneNumber,
                dob: dob,
                gender: gender,
                uid: uid,
                isGuest: isGuest,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. KHOANG ẢNH CHỤP
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[200],
              child: _buildImageWidget(item),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. KẾT QUẢ PHÂN TÍCH
                  Text('Kết quả từ AI', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: AppSizes.p8),
                  Text(item.diseaseName,
                      style: AppTextStyles.heading1
                          .copyWith(color: AppColors.primaryDark)),
                  const SizedBox(height: AppSizes.p16),
                  Row(
                    children: [
                      _buildInfoChip(
                          icon: Icons.access_time,
                          label: DateFormat('dd/MM/yyyy - HH:mm')
                              .format(item.date),
                          color: Colors.blueGrey),
                      const SizedBox(width: AppSizes.p12),
                      _buildInfoChip(
                          icon: Icons.security,
                          label: 'Tin cậy: $displayConfidence%',
                          color: statusColor),
                    ],
                  ),
                  const Divider(height: AppSizes.p32, thickness: 1),

                  // 3. THÔNG TIN BỆNH LÝ TỪ AI (GENERATED BY AI)
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary),
                      const SizedBox(width: AppSizes.p8),
                      Text('Thông tin bệnh lý (AI Generated)',
                          style: AppTextStyles.heading2),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),

                  // 💡 SỬ DỤNG OBX ĐỂ LẮNG NGHE DỮ LIỆU TỪ AI
                  Obx(() {
                    if (aiController.isLoading.value) {
                      return _buildShimmerLoading(); // Hiển thị hiệu ứng chờ
                    }

                    return Container(
                      padding: const EdgeInsets.all(AppSizes.p20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mô tả sơ bộ:',
                              style: AppTextStyles.heading2
                                  .copyWith(fontSize: 16)),
                          const SizedBox(height: AppSizes.p8),
                          Text(aiController.description.value,
                              style: AppTextStyles.body.copyWith(
                                  height: 1.5, color: Colors.black87)),
                          const SizedBox(height: AppSizes.p20),
                          if (aiController.causes.isNotEmpty) ...[
                            Text('Nguyên nhân & Nguy cơ:',
                                style: AppTextStyles.heading2
                                    .copyWith(fontSize: 16)),
                            const SizedBox(height: AppSizes.p8),
                            ...aiController.causes.map((cause) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Icon(Icons.circle,
                                            size: 8, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(cause,
                                              style: AppTextStyles.body
                                                  .copyWith(height: 1.4))),
                                    ],
                                  ),
                                )),
                          ],
                          if (aiController.citation.value.isNotEmpty) ...[
                            const SizedBox(height: AppSizes.p16),
                            const Divider(height: 1, thickness: 0.5, color: Colors.blueAccent),
                            const SizedBox(height: AppSizes.p12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.bookmark_outline_rounded,
                                    size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    aiController.citation.value,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textSecondary,
                                        height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: AppSizes.p24),

                  // 4. NÚT CHAT VỚI BÁC SĨ AI (TƯ VẤN SÂU)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.offAllNamed(Routes.MAIN, arguments: 3);
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          color: Colors.white),
                      label: const Text('Tư Vấn Với Bác Sĩ AI',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.p24),
                  const MedicalDisclaimer(),
                  const SizedBox(height: AppSizes.p32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(ScanModel item) {
    if (item.localImagePath.isNotEmpty) {
      final file = File(item.localImagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
        );
      }
    }
    if (item.firebaseImageUrl.isNotEmpty) {
      return Image.network(
        item.firebaseImageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      );
    }
    return const Center(
        child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey));
  }

  Widget _buildInfoChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  // Khung giả lập (Skeleton) hiển thị khi AI đang suy nghĩ tạo chữ
  Widget _buildShimmerLoading() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('AI đang tổng hợp dữ liệu y khoa...',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
              height: 10, width: double.infinity, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(
              height: 10,
              width: '80%'.tr.length.toDouble() > 0 ? 250 : double.infinity,
              color: Colors.grey[300]),
          const SizedBox(height: 8),
          Container(
              height: 10,
              width: '60%'.tr.length.toDouble() > 0 ? 180 : double.infinity,
              color: Colors.grey[300]),
        ],
      ),
    );
  }
}
