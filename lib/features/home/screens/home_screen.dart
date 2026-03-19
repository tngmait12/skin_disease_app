import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../core/widgets/appbar_with_drawer.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../camera/screens/custom_camera_screen.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithDrawer(
        title: 'Chẩn Đoán Da Liễu V2',
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
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const CustomCameraScreen());
                    },
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

class ScannerAnimation extends StatefulWidget {
  const ScannerAnimation({Key? key}) : super(key: key);

  @override
  State<ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Tạo hiệu ứng lặp đi lặp lại trong 2 giây
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          // Trượt từ trên cùng (0) xuống dưới cùng (1)
          top: _animationController.value * 380, // 380 là chiều cao khung trừ đi độ dày tia sáng
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.tealAccent,
              boxShadow: [
                BoxShadow(color: Colors.tealAccent.withOpacity(0.8), blurRadius: 15, spreadRadius: 5),
              ],
            ),
          ),
        );
      },
    );
  }
}