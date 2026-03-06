import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skin_disease_app/features/history/models/history_model.dart';
import 'package:skin_disease_app/features/history/screens/history_detail_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chẩn đoán'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_graph_outlined),
            onPressed: controller.goToDashboard,
            tooltip: 'Insights',
          ),
        ],
      ),
      body: Obx(() {
        // Trạng thái trống (Không có lịch sử)
        if (controller.historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có dữ liệu lịch sử',
                  style: AppTextStyles.heading2.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Các kết quả chẩn đoán sẽ được lưu tại đây.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          );
        }

        // Trạng thái có dữ liệu
        return ListView.separated(
          padding: const EdgeInsets.all(AppSizes.p16),
          itemCount: controller.historyList.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
          itemBuilder: (context, index) {
            final item = controller.historyList[index];

            // Tính toán màu sắc dựa trên độ tin cậy
            final double confidenceValue = item.confidence;
            final String displayConfidence = confidenceValue.toStringAsFixed(2);
            Color statusColor;
            if (confidenceValue >= 80) {
              statusColor = AppColors.success;
            } else if (confidenceValue >= 50) {
              statusColor = AppColors.warning;
            } else {
              statusColor = AppColors.error;
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                onTap: (){
                  Get.to(() => HistoryDetailScreen(item: item));
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  child: Row(
                    children: [
                      // Cột 1: Ảnh Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        child: Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: item.imagePath.isNotEmpty ? Image.network(
                            item.imagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          )
                              : const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p16),
                
                      // Cột 2: Thông tin chính
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.diseaseName,
                                    style: AppTextStyles.heading2.copyWith(fontSize: 16),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                    onPressed: () {
                                      controller.deleteHistoryItem(item);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                
                            // DÒNG 2: Tag Mức độ + % Tin cậy
                            Row(
                              children: [
                                // Tag 1: Mức độ (Tạm thời giả lập dựa trên Confidence, bạn có thể chỉnh lại logic sau)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    confidenceValue >= 80 ? 'Nghiêm trọng' : (confidenceValue >= 50 ? 'Trung bình' : 'Nhẹ'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                
                                // Tag 2: % Độ tin cậy + Icon Khiên
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.security, size: 14, color: Colors.blueGrey), // Icon khiên
                                      const SizedBox(width: 4),
                                      Text(
                                        '$displayConfidence%',
                                        style: TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                
                            // DÒNG 3: Ngày giờ
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy - HH:mm').format(item.date),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}