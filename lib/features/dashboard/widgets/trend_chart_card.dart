import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/dashboard_controller.dart';

class TrendChartCard extends StatelessWidget {
  const TrendChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSizes.p8),
              Text('Xu hướng sức khỏe', style: AppTextStyles.heading2),
            ],
          ),
          const SizedBox(height: AppSizes.p4),
          Container(
            height: 220,
            padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            // LÁ CHẮN BẢO VỆ: Tránh lỗi khi danh sách dữ liệu rỗng
            child: controller.latestDisease.value == 'Chưa có dữ liệu'
                ? const Center(
                    child: Text(
                      'Chưa có đủ dữ liệu để vẽ biểu đồ xu hướng',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : controller.trendData.length == 1
                    ? _buildSingleDataPointOnboarding(controller.trendData.first.y)
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false, // Ẩn kẻ dọc cho thoáng
                            drawHorizontalLine: true, // Hiện kẻ ngang
                            horizontalInterval: 20, // Kẻ 1 đường mỗi 20 điểm
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2), // Màu xám nhạt
                                strokeWidth: 2,
                                dashArray: [5, 5],
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < controller.trendDayLabels.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${controller.trendDayLabels[index]}',
                                        style: AppTextStyles.caption,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),

                          // ĐỂ TỰ ĐỘNG SCALE DỮ LIỆU: Lấy x nhỏ nhất và lớn nhất trực tiếp từ list
                          minX: 0,
                          maxX: 6,

                          minY: 0,
                          maxY: 100, // Điểm sức khỏe vẫn là thang 100
                          lineBarsData: [
                            LineChartBarData(
                              spots: controller.trendData,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (spot) => Colors.white,
                              tooltipBorderRadius: const BorderRadius.all(Radius.circular(12)),
                              tooltipBorder: BorderSide(color: Colors.grey.withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      );
    });
  }

  // Phương thức hiển thị giao diện Onboarding khi người dùng chỉ có 1 ngày dữ liệu quét đầu tiên
  Widget _buildSingleDataPointOnboarding(double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p8, vertical: AppSizes.p4),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.toInt()}',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    'Điểm',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppSizes.p20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lần quét đầu tiên! 🎉',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSizes.p6),
                Text(
                  'Hệ thống cần tối thiểu 2 ngày dữ liệu để vẽ biểu đồ xu hướng sức khỏe. Hãy tiếp tục theo dõi da vào ngày mai nhé!',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
