import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Health Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentStatusCard(),
            const SizedBox(height: AppSizes.p24),
            _buildTrendChartCard(),
            const SizedBox(height: AppSizes.p24),
            _buildConditionsBreakdownCard(),
            const SizedBox(height: AppSizes.p32),
          ],
        ),
      ),
    );
  }

  // Phân vùng 1: Trạng thái hiện tại (Lần quét gần nhất)
  Widget _buildCurrentStatusCard() {
    return Container(
      padding: EdgeInsets.all(AppSizes.p20),
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
              Text('Lần quét gần nhất', style: AppTextStyles.body.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(controller.latestStatus.value, style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: AppSizes.p12),
          Text(controller.latestDisease.value, style: AppTextStyles.heading1.copyWith(color: Colors.white)),
          const SizedBox(height: AppSizes.p4),
          Text(controller.latestDate.value, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  // Phân vùng 2: Biểu đồ xu hướng sức khỏe
  Widget _buildTrendChartCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Xu hướng sức khỏe (6 tháng)', style: AppTextStyles.heading2),
        const SizedBox(height: AppSizes.p16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('T${value.toInt()}', style: AppTextStyles.caption),
                      );
                    },
                    interval: 1,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 1,
              maxX: 6,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: controller.trendData,
                  isCurved: true, // Đường cong mềm mại
                  color: AppColors.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true), // Hiện các chấm
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.1), // Đổ bóng mờ dưới biểu đồ
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Phân vùng 3: Thống kê tỷ lệ bệnh lý
  Widget _buildConditionsBreakdownCard() {
    // Tính tổng số ca để tính %
    final double totalScans = controller.conditionsData.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tỷ lệ phát hiện bệnh lý', style: AppTextStyles.heading2),
        const SizedBox(height: AppSizes.p16),
        Container(
          padding: const EdgeInsets.all(AppSizes.p16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: controller.conditionsData.entries.map((entry) {
              final double percentage = (entry.value / totalScans);

              // Tùy chỉnh màu sắc tùy theo loại bệnh
              Color barColor = AppColors.primary;
              if (entry.key.contains('Normal')) barColor = AppColors.success;
              if (entry.key.contains('Melanoma')) barColor = AppColors.error;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                        Text('${(percentage * 100).toInt()}%', style: AppTextStyles.bodySecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}