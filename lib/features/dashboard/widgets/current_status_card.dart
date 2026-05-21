import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/widgets/status_badge.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/dashboard_controller.dart';

class CurrentStatusCard extends StatelessWidget {
  const CurrentStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.visibility,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.p8),
              Text('Current Status', style: AppTextStyles.heading2),
            ],
          ),
          const SizedBox(height: AppSizes.p4),
          Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lần quét gần nhất',
                      style: AppTextStyles.bodySecondary.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Flexible(
                      child: StatusBadge(statusText: controller.latestStatus.value),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  controller.latestDisease.value,
                  style: AppTextStyles.heading1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  controller.latestDate.value,
                  style: AppTextStyles.bodySecondary.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSizes.p4),
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Confidence:',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Text(
                      '${(controller.latestConfidence.value).toStringAsFixed(2)}%',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p8),

                // 4. THANH PROGRESS BAR (Bo góc)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (controller.latestConfidence.value / 100),
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
