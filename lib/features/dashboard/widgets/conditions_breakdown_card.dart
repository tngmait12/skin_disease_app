import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/dashboard_controller.dart';

class ConditionsBreakdownCard extends StatelessWidget {
  const ConditionsBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      // 1. LÁ CHẮN BẢO VỆ 1: Nếu chưa có dữ liệu, ngắt hàm luôn và trả về UI "Trống"
      if (controller.conditionsData.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tỷ lệ phát hiện bệnh lý', style: AppTextStyles.heading2),
            const SizedBox(height: AppSizes.p16),
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text(
                  'Chưa có dữ liệu phân tích',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      }

      // 2. LÁ CHẮN BẢO VỆ 2: Dùng .fold() thay cho .reduce() để an toàn tuyệt đối với lỗi toán học
      final double totalScans = controller.conditionsData.values.fold(0.0, (sum, item) => sum + item);

      // 3. LÁ CHẮN BẢO VỆ 3: Chặn lỗi chia cho 0 (NaN)
      if (totalScans == 0) return const SizedBox.shrink();

      // Hàm hỗ trợ chọn màu sắc
      Color getSectionColor(String diseaseName, int index) {
        if (diseaseName.contains('Normal')) return AppColors.success;
        if (diseaseName.contains('Melanoma') || diseaseName.contains('Cancer')) return AppColors.error;

        final fallbackColors = [
          AppColors.primary,
          Colors.blueAccent,
          Colors.orangeAccent,
          Colors.purpleAccent,
          Colors.teal,
        ];
        return fallbackColors[index % fallbackColors.length];
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tỷ lệ phát hiện bệnh lý', style: AppTextStyles.heading2),
          const SizedBox(height: AppSizes.p16),
          Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // --- PHẦN 1: BIỂU ĐỒ DONUT CHART ---
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: List.generate(controller.conditionsData.length, (index) {
                            String key = controller.conditionsData.keys.elementAt(index);
                            double value = controller.conditionsData.values.elementAt(index);
                            double percentage = (value / totalScans) * 100;

                            return PieChartSectionData(
                              color: getSectionColor(key, index),
                              value: value,
                              title: '${percentage.toInt()}%',
                              radius: 25,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Tổng số', style: AppTextStyles.caption.copyWith(color: Colors.grey)),
                            Text(
                              '${totalScans.toInt()}',
                              style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.p24),

                // --- PHẦN 2: BẢNG CHÚ GIẢI (LEGEND) ---
                Column(
                  children: List.generate(controller.conditionsData.length, (index) {
                    String key = controller.conditionsData.keys.elementAt(index);
                    double value = controller.conditionsData.values.elementAt(index);
                    double percentage = (value / totalScans) * 100;
                    Color color = getSectionColor(key, index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: AppSizes.p12),
                          Expanded(
                            child: Text(
                              key,
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodySecondary.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
