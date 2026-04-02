import 'package:flutter/material.dart';

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
            const SizedBox(height: 20), // Tăng khoảng cách lên một chút cho thoáng

            // NÚT TÌM HIỂU CHI TIẾT BỆNH LÝ BỔ SUNG VÀO ĐÂY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Đẩy tên bệnh sang màn hình Chi tiết (để AI giải thích)
                  // Get.to(() => HistoryDetailScreen(item: ));
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