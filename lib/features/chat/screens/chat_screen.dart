import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/chat_controller.dart';


class ChatScreen extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            // Dùng Get.find để lấy chìa khóa từ MainController và mở Drawer
            Get.find<MainController>().scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.psychology_alt, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.p12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Skin Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Luôn sẵn sàng hỗ trợ', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // KHOANG 1: Danh sách tin nhắn
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
              itemBuilder: (context, index) {
                // Nếu đang ở vị trí cuối cùng và isTyping = true -> Hiện chữ "AI đang gõ..."
                if (index == controller.messages.length && controller.isTyping.value) {
                  return _buildTypingIndicator();
                }

                final msg = controller.messages[index];
                return _buildChatBubble(msg);
              },
            )),
          ),

          // KHOANG 2: Ô nhập liệu (Input Field)
          _buildInputArea(),
        ],
      ),
    );
  }

  // Widget: Bong bóng chat
  Widget _buildChatBubble(dynamic msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.8, // Giới hạn chiều rộng bong bóng
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: isUser ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: isUser
            ? Text(
          msg.text,
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
        )
            : MarkdownBody(
          data: msg.text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            // Chữ thường
            p: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.5),
            // Chữ in đậm (**chữ**)
            strong: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            // Tiêu đề (###)
            h3: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
            // Màu của dấu gạch đầu dòng
            listBullet: const TextStyle(color: AppColors.primary, fontSize: 16),
            // Chữ in nghiêng (*chữ*) - Dùng cho các cảnh báo y tế
            em: const TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic, fontSize: 14),
          ),
        ),
      ),
    );
  }

  // Widget: AI đang gõ
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text('AI đang phân tích...', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // Widget: Ô nhập liệu dưới cùng
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi về da của bạn...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.sendMessage(), // Bấm Enter trên bàn phím cũng gửi được
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: controller.sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}