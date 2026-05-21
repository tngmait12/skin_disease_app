import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/scan_model.dart';
import '../../history/controllers/history_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  final RxInt selectedCategory = 0.obs;

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
            onPressed: () => _showSavedTipsBottomSheet(context),
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
                return _buildWelcomeState(context);
              }
              return ListView.builder(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: controller.messages.length + (controller.isTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Nếu đang ở vị trí cuối cùng và isTyping = true -> Hiện typing indicator
                  if (index == controller.messages.length && controller.isTyping.value) {
                    return _buildTypingIndicator();
                  }

                  final msg = controller.messages[index];
                  return _buildChatBubble(msg);
                },
              );
            }),
          ),

          // KHOANG 2: Xem trước ảnh đính kèm & Ô nhập liệu
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAttachmentPreview(),
              _buildInputArea(context),
            ],
          ),
        ],
      ),
    );
  }

  // Giao diện chào mừng khi chưa có cuộc hội thoại nào
  Widget _buildWelcomeState(BuildContext context) {
    final categories = [
      {'name': 'Mụn & Thâm', 'icon': '🔥'},
      {'name': 'Routine Chăm sóc', 'icon': '🧴'},
      {'name': 'Hoạt chất', 'icon': '🧪'},
      {'name': 'Phục hồi Da', 'icon': '🛡️'},
    ];

    final Map<int, List<Map<String, String>>> categoryPrompts = {
      0: [
        {'title': 'Trị mụn ẩn dai dẳng', 'desc': 'Routine đẩy mụn ẩn & mờ thâm nhanh chóng', 'icon': '💡'},
        {'title': 'Mụn bọc sưng đỏ', 'desc': 'Routine cấp cứu mụn sưng viêm an toàn', 'icon': '🚨'},
      ],
      1: [
        {'title': 'Dưỡng da khô ráp', 'desc': 'Routine cấp ẩm mướt mịn cả ngày', 'icon': '💦'},
        {'title': 'Kiềm dầu tối ưu', 'desc': 'Hạn chế đổ dầu thừa vùng chữ T', 'icon': '✨'},
      ],
      2: [
        {'title': 'BHA & Niacinamide', 'desc': 'Hướng dẫn kết hợp chuẩn khoa học', 'icon': '🔬'},
        {'title': 'Retinol cho F0', 'desc': 'Nồng độ và tần suất dùng an toàn', 'icon': '🌙'},
      ],
      3: [
        {'title': 'Hàng rào bảo vệ', 'desc': 'Dấu hiệu tổn thương và cách khôi phục', 'icon': '🩹'},
        {'title': 'Cấp cứu kích ứng', 'desc': 'Làm dịu da mẩn đỏ khẩn cấp', 'icon': '❄️'},
      ],
    };

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24, vertical: AppSizes.p32),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.p8),
          // Gradient Circle Avatar
          Container(
            padding: const EdgeInsets.all(AppSizes.p24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSizes.p24),
          const Text(
            'Trợ Lý Da Liễu AI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSizes.p12),
          const Text(
            'Xin chào! Tôi có thể tư vấn chăm sóc da khoa học, phân tích tác dụng hoạt chất và đặc biệt là phân tích hình ảnh chẩn đoán của bạn để tư vấn chuyên sâu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 36),
          
          // Tiêu đề câu hỏi gợi ý
          const Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.assistant_navigation, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Gợi ý câu hỏi phổ biến:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // Lựa chọn danh mục câu hỏi dạng tab
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Obx(() {
                  final isSelected = selectedCategory.value == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(
                        '${cat['icon']} ${cat['name']}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (_) {
                        selectedCategory.value = index;
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  );
                });
              },
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          
          // Grid gợi ý câu hỏi theo tab
          Obx(() {
            final prompts = categoryPrompts[selectedCategory.value] ?? [];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  child: InkWell(
                    onTap: () {
                      controller.textController.text = 'Hãy tư vấn cho tôi về: ${prompt['title']} (${prompt['desc']})';
                      controller.sendMessage();
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prompt['icon']!,
                            style: const TextStyle(fontSize: 22),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prompt['title']!,
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
                                prompt['desc']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // Bong bóng chat hiển thị ảnh và tư vấn da liễu
  Widget _buildChatBubble(ChatMessageModel msg) {
    final isUser = msg.isUser;
    final hasImage = msg.localImagePath != null || msg.imageUrl != null;

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
                  child: msg.localImagePath != null && File(msg.localImagePath!).existsSync()
                      ? Image.file(File(msg.localImagePath!), fit: BoxFit.cover)
                      : (msg.imageUrl != null
                          ? Image.network(msg.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                          : const Icon(Icons.image)),
                ),
              ),
              const SizedBox(height: 8),
              if (msg.diseaseName != null) ...[
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
                          'Chẩn đoán: ${msg.diseaseName} (${(msg.confidence! * 100).toStringAsFixed(1)}%)',
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
                    msg.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: msg.text,
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
                              Clipboard.setData(ClipboardData(text: msg.text));
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
                            final isSaved = controller.isBookmarked(msg.text);
                            return IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                                size: 18,
                                color: isSaved ? AppColors.success : AppColors.textSecondary,
                              ),
                              tooltip: isSaved ? 'Đã lưu trong Sổ tay' : 'Lưu vào Sổ tay',
                              onPressed: () => controller.toggleBookmarkTip(msg),
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

  // Khung xem trước hình ảnh đính kèm trên thanh nhập liệu
  Widget _buildAttachmentPreview() {
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

  // Typing indicator với 3 dấu chấm nhấp nhô tuyệt đẹp
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.p16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_alt, color: AppColors.primary, size: 14),
            ),
            const SizedBox(width: 12),
            const TypingIndicator(),
            const SizedBox(width: 10),
            Text(
              'AI đang phân tích...',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Menu tùy chọn đính kèm ảnh (Chụp/Thư viện/Lịch sử)
  void _showAttachmentOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chọn nguồn đính kèm hình ảnh',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOptionCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Chụp ảnh da',
                  color: AppColors.primary,
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildAttachmentOptionCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Thư viện ảnh',
                  color: AppColors.primaryLight,
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
                _buildAttachmentOptionCard(
                  icon: Icons.history_rounded,
                  label: 'Lịch sử quét',
                  color: AppColors.success,
                  onTap: () {
                    Get.back();
                    _showScanHistorySelector(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách lựa chọn lịch sử quét da
  void _showScanHistorySelector(BuildContext context) {
    final HistoryController historyController = Get.find<HistoryController>();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
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
                  const Icon(Icons.history_edu_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Đính Kèm Lịch Sử Quét',
                    style: TextStyle(
                      fontSize: 17,
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
                if (historyController.historyList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        const Text(
                          'Bạn chưa có lịch sử chẩn đoán nào',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: historyController.historyList.length,
                  itemBuilder: (context, index) {
                    final scan = historyController.historyList[index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      child: InkWell(
                        onTap: () {
                          controller.attachScan(scan);
                          Get.back(); // Đóng bottom sheet
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade100,
                                  child: scan.localImagePath.isNotEmpty && File(scan.localImagePath).existsSync()
                                      ? Image.file(File(scan.localImagePath), fit: BoxFit.cover)
                                      : (scan.firebaseImageUrl.isNotEmpty
                                          ? Image.network(scan.firebaseImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                                          : const Icon(Icons.image, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scan.diseaseName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Độ chính xác: ${(scan.confidence * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: scan.confidence > 0.7 ? AppColors.success : AppColors.warning,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                            ],
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
      ),
      isScrollControlled: true,
    );
  }

  // Sổ tay Da liễu cá nhân - Chứa các lời khuyên đã đánh dấu
  void _showSavedTipsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
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
                                  color: AppColors.textPrimary,
                                ),
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
      ),
      isScrollControlled: true,
    );
  }

  // Floating Input Area thiết kế hiện đại, hỗ trợ gõ nhiều dòng tự lớn lên
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút đính kèm ảnh
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 22),
                onPressed: () => _showAttachmentOptions(context),
              ),
            ),
            const SizedBox(width: 8),

            // Ô nhập liệu text
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        maxLines: 4,
                        minLines: 1,
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Nhập thắc mắc về làn da...',
                          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Nút gửi tin nhắn
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: controller.sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Lớp hoạt cảnh nhấp nhô 3 dấu chấm nhấp nháy cho Trợ lý AI đang gõ
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double progress = (_controller.value - (index * 0.2)) % 1.0;
            final double dy = -6.0 * (progress < 0.5 ? (progress * 2.0) : (2.0 - progress * 2.0));
            
            return Transform.translate(
              offset: Offset(0, dy),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}