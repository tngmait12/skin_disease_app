import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/onboarding_controller.dart';


class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());


    final List<Map<String, String>> onboardingData = [
      {
        "title": "Chụp ảnh vùng da",
        "description": "Chụp rõ nét vùng da đang gặp vấn đề dưới ánh sáng tốt để hệ thống phân tích chính xác nhất.",
        "icon": "camera_alt_outlined"
      },
      {
        "title": "AI Phân tích thông minh",
        "description": "Mô hình trí tuệ nhân tạo sẽ tự động quét và nhận diện các dấu hiệu bệnh lý trên làn da của bạn.",
        "icon": "auto_awesome_outlined"
      },
      {
        "title": "Theo dõi hồ sơ sức khỏe",
        "description": "Lưu trữ lịch sử khám và theo dõi mức độ cải thiện của làn da qua từng ngày trực quan.",
        "icon": "analytics_outlined"
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.finishOnboarding,
                child: Text('Skip', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSizes.p32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //(file ảnh hoặc Lottie Animation)
                        Icon(
                          _getIconData(onboardingData[index]["icon"]!),
                          size: 120,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: AppSizes.p48),
                        Text(
                          onboardingData[index]["title"]!,
                          style: AppTextStyles.heading1.copyWith(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.p16),
                        Text(
                          onboardingData[index]["description"]!,
                          style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Khu vực điều hướng (Chấm tròn + Nút bấm)
            Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Các chấm tròn (Indicators)
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: controller.currentPage.value == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppColors.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: AppSizes.p32),

                  // Nút Next
                  Obx(() => SizedBox(
                    width: double.infinity, // Làm cho nút to ra bằng chiều ngang màn hình
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16), // Nút bấm dày hơn một chút
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        controller.currentPage.value == onboardingData.length - 1
                            ? 'Bắt đầu ngay'
                            : 'Tiếp tục',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'camera_alt_outlined': return Icons.camera_alt_outlined;
      case 'auto_awesome_outlined': return Icons.auto_awesome_outlined;
      case 'analytics_outlined': return Icons.analytics_outlined;
      default: return Icons.help_outline;
    }
  }
}