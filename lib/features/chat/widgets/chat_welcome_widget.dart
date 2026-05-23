import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/chat_controller.dart';

class ChatWelcomeWidget extends StatelessWidget {
  const ChatWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find<ChatController>();
    final RxInt selectedCategory = 0.obs;

    final categories = [
      {'name': 'Mụn & Thâm', 'icon': Icons.local_fire_department_rounded},
      {'name': 'Routine Chăm sóc', 'icon': Icons.spa_rounded},
      {'name': 'Hoạt chất', 'icon': Icons.science_outlined},
      {'name': 'Phục hồi Da', 'icon': Icons.shield_outlined},
    ];

    final Map<int, List<Map<String, dynamic>>> categoryPrompts = {
      0: [
        {'title': 'Trị mụn ẩn dai dẳng', 'desc': 'Routine đẩy mụn ẩn & mờ thâm nhanh chóng', 'icon': Icons.lightbulb_outline_rounded},
        {'title': 'Mụn bọc sưng đỏ', 'desc': 'Routine cấp cứu mụn sưng viêm an toàn', 'icon': Icons.warning_amber_rounded},
      ],
      1: [
        {'title': 'Dưỡng da khô ráp', 'desc': 'Routine cấp ẩm mướt mịn cả ngày', 'icon': Icons.water_drop_outlined},
        {'title': 'Kiềm dầu tối ưu', 'desc': 'Hạn chế đổ dầu thừa vùng chữ T', 'icon': Icons.auto_awesome_rounded},
      ],
      2: [
        {'title': 'BHA & Niacinamide', 'desc': 'Hướng dẫn kết hợp chuẩn khoa học', 'icon': Icons.biotech_outlined},
        {'title': 'Retinol cho F0', 'desc': 'Nồng độ và tần suất dùng an toàn', 'icon': Icons.nightlight_round},
      ],
      3: [
        {'title': 'Hàng rào bảo vệ', 'desc': 'Dấu hiệu tổn thương và cách khôi phục', 'icon': Icons.healing_outlined},
        {'title': 'Cấp cứu kích ứng', 'desc': 'Làm dịu da mẩn đỏ khẩn cấp', 'icon': Icons.ac_unit_rounded},
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
                      avatar: Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                      label: Text(
                        cat['name'] as String,
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
                          Icon(
                            prompt['icon'] as IconData,
                            size: 24,
                            color: AppColors.primary,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prompt['title'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                prompt['desc'] as String,
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
}
