import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../features/home/controllers/home_controller.dart';

class ResultDiseaseCard extends StatelessWidget {
  const ResultDiseaseCard({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
            
            // 📊 DANH SÁCH CÁC CHẨN ĐOÁN PHÂN BIỆT KHÁC (DIFFERENTIAL DIAGNOSES)
            Obx(() {
              if (controller.alternativePredictions.length > 1) {
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bar_chart_rounded, color: Colors.teal),
                    title: const Text(
                      'Chẩn đoán phân biệt khác',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 4),
                      // Hiển thị tối đa 4 ứng cử viên bệnh lý hàng đầu tiếp theo
                      ...controller.alternativePredictions.skip(1).take(4).map((pred) {
                        final double val = double.tryParse(pred['confidence'].toString()) ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pred['disease_name'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${pred['confidence']}%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: val >= 30.0 ? Colors.orange[700] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Thanh tiến trình ngang minh họa độ tin cậy rực rỡ
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: val / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    val >= 30.0 ? Colors.orangeAccent : Colors.teal.withOpacity(0.4),
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (controller.latestScan.value != null) {
                    Get.toNamed(Routes.HISTORY_DETAIL, arguments: controller.latestScan.value!);
                  } else {
                    Get.snackbar(
                      'Thông báo',
                      'Không tìm thấy dữ liệu chẩn đoán mới nhất.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                label: const Text(
                  'Tìm hiểu chi tiết bệnh',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white // Ép màu trắng cho chữ
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal, // Đồng bộ màu Teal với Card
                  foregroundColor: Colors.white, // Phủ màu trắng cho Icon và hiệu ứng nhấn
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}