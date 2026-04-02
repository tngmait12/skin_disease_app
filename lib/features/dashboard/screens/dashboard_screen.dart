import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skin_disease_app/core/widgets/appbar_with_drawer.dart';
import 'package:skin_disease_app/core/widgets/status_badge.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBarWithDrawer(
          title: 'Skin Health Dashboard',
      ),
      body: Obx(() {
        return SingleChildScrollView(
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
        );
      }),
    );
  }

  // Phân vùng 1: Trạng thái hiện tại
  Widget _buildCurrentStatusCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
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
                  Text('Lần quét gần nhất',
                      style: AppTextStyles.bodySecondary.copyWith(color: Colors.white70)),
                  const SizedBox(width: AppSizes.p8),
                  Flexible(
                    child: StatusBadge(statusText: controller.latestStatus.value),
                  )
                ],
              ),
              const SizedBox(height: AppSizes.p4),
              Text(controller.latestDisease.value, style: AppTextStyles.heading1.copyWith(color: Colors.white)),
              const SizedBox(height: AppSizes.p4),
              Text(controller.latestDate.value, style: AppTextStyles.bodySecondary.copyWith(color: Colors.white70)),
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
                    // Giả sử biến confidence lưu từ 0-100. toStringAsFixed(1) để lấy 1 số thập phân (VD: 95.5%)
                    '${(controller.latestConfidence.value).toStringAsFixed(2)}%',
                    style: AppTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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
  }

  // Phân vùng 2: Biểu đồ xu hướng sức khỏe
  Widget _buildTrendChartCard() {
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
          child: controller.trendData.isEmpty
              ? const Center(
            child: Text('Chưa có đủ dữ liệu để vẽ biểu đồ', style: TextStyle(color: Colors.grey)),
          )
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
                    // Bỏ interval cứng đi để thư viện tự động tính toán khoảng cách label cho đẹp
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
            ),
          ),
        ),
      ],
    );
  }

  // Phân vùng 3: Thống kê tỷ lệ bệnh lý
  Widget _buildConditionsBreakdownCard() {
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
                  style: TextStyle(color: Colors.grey)
              ),
            ),
          ),
        ],
      );
    }

    // 2. LÁ CHẮN BẢO VỆ 2: Dùng .fold() thay cho .reduce() để an toàn tuyệt đối với lỗi toán học
    final double totalScans = controller.conditionsData.values.fold(0.0, (sum, item) => sum + item);

    // 3. LÁ CHẮN BẢO VỆ 3: Chặn lỗi chia cho 0 (NaN)
    if (totalScans == 0) return const SizedBox();

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

    // ... (Phần UI vẽ PieChart và Legend của bạn giữ nguyên ở dưới đây)
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
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          );
                        }),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Tổng số', style: AppTextStyles.caption.copyWith(color: Colors.grey)),
                          Text('${totalScans.toInt()}', style: AppTextStyles.heading1.copyWith(color: AppColors.primary)),
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
                        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Text(key, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text('${percentage.toStringAsFixed(1)}%', style: AppTextStyles.bodySecondary.copyWith(fontWeight: FontWeight.bold)),
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
  }

// Phân vùng 3: Thống kê tỷ lệ bệnh lý (Nâng cấp thành Donut Chart)
//   Widget _buildConditionsBreakdownCard() {
//     final double totalScans = controller.conditionsData.values.reduce((a, b) => a + b);
//
//     Color getSectionColor(String diseaseName, int index) {
//       if (diseaseName == 'Chưa có dữ liệu') return Colors.grey[300]!;
//       if (diseaseName.contains('Normal')) return AppColors.success;
//       if (diseaseName.contains('Melanoma') || diseaseName.contains('Cancer')) return AppColors.error;
//
//       final fallbackColors = [
//         AppColors.primary,
//         Colors.blueAccent,
//         Colors.orangeAccent,
//         Colors.purpleAccent,
//         Colors.teal,
//       ];
//       return fallbackColors[index % fallbackColors.length];
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(
//               Icons.pie_chart_outline,
//               color: AppColors.primary,
//               size: 24,
//             ),
//             const SizedBox(width: AppSizes.p8),
//             Text('Tỷ lệ phát hiện bệnh lý', style: AppTextStyles.heading2),
//           ],
//         ),
//         const SizedBox(height: AppSizes.p16),
//         Container(
//           padding: const EdgeInsets.all(AppSizes.p20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
//             border: Border.all(color: Colors.grey.withOpacity(0.2)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.02),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // --- PHẦN 1: BIỂU ĐỒ DONUT CHART ---
//               SizedBox(
//                 height: 200,
//                 child: Stack(
//                   children: [
//                     PieChart(
//                       PieChartData(
//                         sectionsSpace: 2, // Khoảng cách mỏng giữa các lát cắt
//                         centerSpaceRadius: 60, // Tạo lỗ hổng ở giữa thành Donut
//                         sections: List.generate(controller.conditionsData.length, (index) {
//                           String key = controller.conditionsData.keys.elementAt(index);
//                           double value = controller.conditionsData.values.elementAt(index);
//                           double percentage = (value / totalScans) * 100;
//
//                           return PieChartSectionData(
//                             color: getSectionColor(key, index),
//                             value: value,
//                             title: '${percentage.toInt()}%',
//                             radius: 25, // Độ dày của vòng tròn
//                             titleStyle: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                     // Chữ nằm ở tâm của Donut Chart
//                     Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text('Tổng số', style: AppTextStyles.caption.copyWith(color: Colors.grey)),
//                           Text('${totalScans.toInt()}', style: AppTextStyles.heading1.copyWith(color: AppColors.primary)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: AppSizes.p24),
//
//               // --- PHẦN 2: BẢNG CHÚ GIẢI (LEGEND) ---
//               Column(
//                 children: List.generate(controller.conditionsData.length, (index) {
//                   String key = controller.conditionsData.keys.elementAt(index);
//                   double value = controller.conditionsData.values.elementAt(index);
//                   double percentage = (value / totalScans) * 100;
//                   Color color = getSectionColor(key, index);
//
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: Row(
//                       children: [
//                         // Dấu chấm màu
//                         Container(
//                           width: 14,
//                           height: 14,
//                           decoration: BoxDecoration(
//                             color: color,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(width: AppSizes.p12),
//                         // Tên bệnh
//                         Expanded(
//                           child: Text(
//                             key,
//                             style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         // Phần trăm
//                         Text(
//                           '${percentage.toStringAsFixed(1)}%',
//                           style: AppTextStyles.bodySecondary.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
}