import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message_model.dart';
import '../controllers/chat_controller.dart';

class SavedTipsSheet extends StatelessWidget {
  const SavedTipsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();

    return Container(
      height: Get.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 26),
                const SizedBox(width: 10),
                const Text(
                  'Sổ Tay Lời Khuyên Da Liễu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.savedTips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Sổ tay của bạn đang trống',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bấm vào biểu tượng lưu trên tin nhắn AI để thêm lời khuyên hữu ích!',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.savedTips.length,
                itemBuilder: (context, index) {
                  final tip = controller.savedTips[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.spa_rounded, color: AppColors.success, size: 18),
                            ),
                            title: Text(
                              tip['text'].toString().split('\n').first.replaceAll(RegExp(r'[#\*]'), ''),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Đã lưu lúc: ${DateTime.parse(tip['timestamp']).day}/${DateTime.parse(tip['timestamp']).month}/${DateTime.parse(tip['timestamp']).year}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                              onPressed: () {
                                final mockMsg = ChatMessageModel(text: tip['text'], isUser: false);
                                controller.toggleBookmarkTip(mockMsg);
                              },
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MarkdownBody(
                                      data: tip['text'],
                                      selectable: true,
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.5),
                                        strong: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                        h3: const TextStyle(color: AppColors.primaryDark, fontSize: 15, fontWeight: FontWeight.bold, height: 1.4),
                                        listBullet: const TextStyle(color: AppColors.primary, fontSize: 14),
                                        em: const TextStyle(color: AppColors.error, fontStyle: FontStyle.italic, fontSize: 12.5),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.copy_rounded, size: 16),
                                        label: const Text('Sao chép lời khuyên', style: TextStyle(fontSize: 12)),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: tip['text']));
                                          Get.snackbar('Đã sao chép', 'Lời khuyên đã được lưu vào bộ nhớ tạm');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
