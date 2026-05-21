import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_attachment_preview.dart';
import '../widgets/chat_bubble_widget.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_typing_indicator.dart';
import '../widgets/chat_welcome_widget.dart';
import '../widgets/saved_tips_sheet.dart';

class ChatScreen extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Get.find<MainController>().scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_alt, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Skin Assistant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                  ),
                  Text(
                    'Luôn sẵn sàng hỗ trợ',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Nút mở Sổ tay da liễu cá nhân
          IconButton(
            icon: const Icon(Icons.bookmark_rounded, size: 24),
            tooltip: 'Sổ tay Da liễu',
            onPressed: () {
              Get.bottomSheet(
                const SavedTipsSheet(),
                isScrollControlled: true,
              );
            },
          ),
          Obx(
            () => controller.messages.length > 1
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded, size: 24),
                    tooltip: 'Xóa lịch sử trò chuyện',
                    onPressed: controller.clearHistory,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // KHOANG 1: Danh sách tin nhắn / Màn hình chào mừng
          Expanded(
            child: Obx(() {
              if (controller.messages.length <= 1 && !controller.isTyping.value) {
                return const ChatWelcomeWidget();
              }
              return ListView.builder(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Nếu đang ở vị trí cuối cùng và isTyping = true -> Hiện typing indicator
                  if (index == controller.messages.length && controller.isTyping.value) {
                    return const ChatTypingIndicator();
                  }

                  final msg = controller.messages[index];
                  return ChatBubbleWidget(message: msg);
                },
              );
            }),
          ),

          // KHOANG 2: Xem trước ảnh đính kèm & Ô nhập liệu
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChatAttachmentPreview(),
              ChatInputArea(),
            ],
          ),
        ],
      ),
    );
  }
}