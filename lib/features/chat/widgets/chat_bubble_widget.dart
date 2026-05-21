import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/chat_message_model.dart';
import '../controllers/chat_controller.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubbleWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final isUser = message.isUser;
    final hasImage = message.localImagePath != null || message.imageUrl != null;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.82,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: isUser ? null : Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nếu có đính kèm ảnh
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: message.localImagePath != null && File(message.localImagePath!).existsSync()
                      ? Image.file(File(message.localImagePath!), fit: BoxFit.cover)
                      : (message.imageUrl != null
                          ? Image.network(message.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                          : const Icon(Icons.image)),
                ),
              ),
              const SizedBox(height: 8),
              if (message.diseaseName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.white24 : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.troubleshoot_rounded, size: 14, color: isUser ? Colors.white : AppColors.primary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Chẩn đoán: ${message.diseaseName} (${(message.confidence! * 100).toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isUser ? Colors.white : AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],

            // Nội dung text
            isUser
                ? Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: message.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.6),
                          strong: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                          h3: const TextStyle(color: AppColors.primaryDark, fontSize: 17, fontWeight: FontWeight.bold, height: 1.5),
                          listBullet: const TextStyle(color: AppColors.primary, fontSize: 16),
                          em: const TextStyle(color: AppColors.error, fontStyle: FontStyle.italic, fontSize: 14),
                          blockSpacing: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Nút sao chép văn bản
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                            tooltip: 'Sao chép',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: message.text));
                              Get.snackbar(
                                'Đã sao chép',
                                'Đã lưu lời khuyên vào bộ nhớ tạm',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.primary.withOpacity(0.9),
                                colorText: Colors.white,
                              );
                            },
                          ),
                          // Nút Lưu/Hủy lưu sổ tay khuyên dùng
                          Obx(() {
                            final isSaved = controller.isBookmarked(message.text);
                            return IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                                size: 18,
                                color: isSaved ? AppColors.success : AppColors.textSecondary,
                              ),
                              tooltip: isSaved ? 'Đã lưu trong Sổ tay' : 'Lưu vào Sổ tay',
                              onPressed: () => controller.toggleBookmarkTip(message),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
