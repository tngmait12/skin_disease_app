import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/chat_controller.dart';

class ChatAttachmentPreview extends StatelessWidget {
  const ChatAttachmentPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();

    return Obx(() {
      final imgPath = controller.selectedImagePath.value;
      final scan = controller.selectedScan.value;

      if (imgPath == null && scan == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            // Thumbnail ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                color: Colors.grey.shade200,
                child: imgPath != null
                    ? Image.file(File(imgPath), fit: BoxFit.cover)
                    : (scan != null && scan.localImagePath.isNotEmpty && File(scan.localImagePath).existsSync()
                        ? Image.file(File(scan.localImagePath), fit: BoxFit.cover)
                        : (scan != null && scan.firebaseImageUrl.isNotEmpty
                            ? Image.network(scan.firebaseImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                            : const Icon(Icons.image))),
              ),
            ),
            const SizedBox(width: 12),
            // Thông tin ảnh đính kèm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imgPath != null ? 'Ảnh đính kèm mới' : (scan != null ? 'Đính kèm: ${scan.diseaseName}' : ''),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    imgPath != null ? 'Sẽ được phân tích bằng AI' : (scan != null ? 'Độ chính xác: ${(scan.confidence * 100).toStringAsFixed(1)}%' : ''),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Nút hủy đính kèm
            IconButton(
              icon: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 22),
              onPressed: controller.clearAttachment,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    });
  }
}
