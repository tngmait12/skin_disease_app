import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/history_model.dart';
import '../../../shared/widgets/medical_disclaimer.dart';


class HistoryDetailScreen extends StatelessWidget {
  final HistoryModel item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Tính toán lại màu sắc dựa trên độ tin cậy để dùng cho UI chi tiết
    final double confidenceValue = item.confidence;
    final String displayConfidence = confidenceValue.toStringAsFixed(2);
    Color statusColor = confidenceValue >= 80
        ? AppColors.success
        : (confidenceValue >= 50 ? AppColors.warning : AppColors.error);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chẩn đoán'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. KHOANG ẢNH CHỤP (Phóng to)
            Container(
              height: 250,
              width: double.infinity,
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
                  : const Center(
                child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. KHOANG KẾT QUẢ PHÂN TÍCH
                  Text('Kết quả từ AI', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: AppSizes.p8),
                  Text(item.diseaseName, style: AppTextStyles.heading1),
                  const SizedBox(height: AppSizes.p16),

                  // Row hiển thị các thông số
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.access_time,
                        label: DateFormat('dd/MM/yyyy - HH:mm').format(item.date),
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: AppSizes.p12),
                      _buildInfoChip(
                        icon: Icons.security,
                        label: 'Tin cậy: $displayConfidence%',
                        color: statusColor,
                      ),
                    ],
                  ),

                  const Divider(height: AppSizes.p32, thickness: 1),

                  // 3. KHOANG THÔNG TIN BỆNH LÝ (Mở rộng Domain Knowledge)
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: AppSizes.p8),
                      Text(
                        'Thông tin bệnh lý',
                        style: AppTextStyles.heading2,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),

                  Container(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50], // Nền xanh nhạt tạo cảm giác y tế
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mô tả sơ bộ:',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        // TODO: Sau này bạn có thể tạo 1 file Map<String, String> để map tên bệnh với mô tả của nó
                        Text(
                          'Đây là phần hiển thị thông tin chi tiết về bệnh ${item.diseaseName}. Bạn có thể tích hợp một bộ từ điển cục bộ (Local Dictionary) hoặc gọi API để lấy thông tin về triệu chứng, nguyên nhân và các khuyến cáo chăm sóc da cơ bản tại nhà.',
                          style: AppTextStyles.body.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: AppSizes.p16),
                        Text(
                          'Khuyến cáo:',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        Text(
                          'Giữ vệ sinh vùng da tổn thương. Không tự ý bôi thuốc khi chưa có chỉ định của bác sĩ.',
                          style: AppTextStyles.body.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.p24),

                  // 4. KHOANG CẢNH BÁO Y TẾ
                  const MedicalDisclaimer(),
                  const SizedBox(height: AppSizes.p32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget nội bộ để tạo các Tag thông số cho đẹp mắt
  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}