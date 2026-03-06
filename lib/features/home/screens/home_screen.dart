import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/medical_disclaimer.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chẩn Đoán Da Liễu'),
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
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(controller.selectedImagePath.value),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
              const SizedBox(height: 24),
              // Main Actions (Khu vực Nút bấm chính)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.black,),
                    label: const Text('Chụp ảnh', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.black12,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.black,),
                    label: const Text('Thư viện', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.black12,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => controller.analyzeImage(),
                icon: const Icon(Icons.analytics_outlined, color: Colors.white,),
                label: const Text('Phân tích', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                // Đang xử lý
                if (controller.isLoading.value) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 10),
                      Text('AI đang phân tích...', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
                    ],
                  );
                }

                // Có kết quả
                if (controller.diseaseName.value.isNotEmpty) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text('KẾT QUẢ CHẨN ĐOÁN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                          const Divider(color: Colors.teal),
                          const SizedBox(height: 10),
                          Text(
                            controller.diseaseName.value,
                            style: const TextStyle(fontSize: 24, color: Colors.redAccent, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Độ tin cậy: ${controller.confidence.value}%',
                            style: const TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  );
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

  // Widget nội bộ để tạo Action Card tái sử dụng trong màn hình này
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.p24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: AppSizes.p16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppSizes.p4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}