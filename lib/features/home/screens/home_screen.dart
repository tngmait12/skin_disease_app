import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/appbar_with_drawer.dart';
import '../../../core/widgets/button_with_icon_text.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../../core/widgets/result_disease_card.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithDrawer(
        title: 'Skin Shield',
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: AppSizes.iconMedium),
            onPressed: controller.goToHistory,
            tooltip: 'Lịch sử khám',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.p16),

              // Hero Section (Lời chào)
              Text(
                'Xin chào!',
                style: AppTextStyles.heading1.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                'Hãy để hệ thống AI hỗ trợ phân tích và kiểm tra tình trạng làn da của bạn ngay hôm nay.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSizes.p32),
              Obx(() => Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: controller.selectedImagePath.value == ''
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Chưa có ảnh nào được chọn', style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(controller.selectedImagePath.value),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0),
                        radius: 18,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          onPressed: controller.clearImage,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              // Main Actions (Khu vực Nút bấm chính)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonWithIconText(
                    icon: Icons.camera_alt,
                    text: 'Chụp ảnh',
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      Get.toNamed(Routes.CAMERA);
                    },
                  ),
                  ButtonWithIconText(
                    icon: Icons.photo_library,
                    text: 'Thư viện',
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.teal.shade700,
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Obx(() {
                final isLoading = controller.isLoading.value;
                return ElevatedButton.icon(
                  onPressed: isLoading ? null : () => controller.analyzeImage(),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.analytics_outlined, color: Colors.white),
                  label: Text(
                    isLoading
                        ? 'Đang phân tích...'
                        : (controller.diseaseName.value.isNotEmpty ? 'Phân tích lại' : 'Phân tích'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.teal.shade300,
                    disabledForegroundColor: Colors.white.withOpacity(0.8),
                    elevation: isLoading ? 1 : 3,
                    shadowColor: Colors.teal.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 10),
                      Text('AI đang phân tích...', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
                    ],
                  );
                }

                if (controller.diseaseName.value.isNotEmpty) {
                  return ResultDiseaseCard(controller: controller);
                }

                // Trạng thái chờ
                return const SizedBox.shrink();
              }),
              // Footer: Cảnh báo y tế
              const SizedBox(height: AppSizes.p16),
              const MedicalDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }
}
