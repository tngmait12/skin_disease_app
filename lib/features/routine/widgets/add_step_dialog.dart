import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/app_icons.dart';
import '../controllers/routine_controller.dart';

class AddStepDialog extends StatefulWidget {
  final bool initialIsMorning;
  const AddStepDialog({super.key, this.initialIsMorning = true});

  @override
  State<AddStepDialog> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<AddStepDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  
  late bool _isMorning;
  String _selectedIconName = 'spa';

  // Danh sách các icon gợi ý đẹp mắt cho Skincare
  final List<Map<String, String>> _skincareIcons = [
    {'name': 'spa', 'label': 'Dưỡng ẩm'},
    {'name': 'water_drop', 'label': 'Làm sạch'},
    {'name': 'wb_sunny', 'label': 'Chống nắng'},
    {'name': 'cleaning_services', 'label': 'Tẩy trang'},
    {'name': 'nightlight_round', 'label': 'Ban đêm'},
    {'name': 'science', 'label': 'Đặc trị'},
    {'name': 'shield', 'label': 'Bảo vệ'},
    {'name': 'local_hospital', 'label': 'Y khoa'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _isMorning = widget.initialIsMorning;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoutineController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // Tự động đẩy lên khi bàn phím xuất hiện
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh kéo dẹt trang trí BottomSheet
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p16),

                // Tiêu đề BottomSheet
                const Text(
                  'Thêm bước chăm sóc tùy chọn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  'Cá nhân hóa quy trình chăm sóc da hàng ngày của bạn.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: AppSizes.p20),

                // 1. INPUT TIÊU ĐỀ BƯỚC
                const Text(
                  'Tên bước chăm sóc *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.p8),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Thoa tinh chất Vitamin C, Bôi Gel B5...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên bước chăm sóc da';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.p16),

                // 2. INPUT MÔ TẢ CHI TIẾT
                const Text(
                  'Hướng dẫn chi tiết',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.p8),
                TextFormField(
                  controller: _descController,
                  maxLength: 150,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Thoa 3-4 giọt lên mặt, massage nhẹ nhàng...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p16),

                // 3. CHỌN BUỔI THỰC HIỆN (SÁNG / TỐI)
                const Text(
                  'Thời điểm áp dụng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.p8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wb_sunny_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Buổi Sáng', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        selected: _isMorning,
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: _isMorning ? AppColors.primary : Colors.grey.shade600,
                        ),
                        side: BorderSide(
                          color: _isMorning ? AppColors.primary : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (selected) {
                          if (selected) setState(() => _isMorning = true);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.nightlight_round_sharp, size: 18),
                            SizedBox(width: 8),
                            Text('Buổi Tối', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        selected: !_isMorning,
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: !_isMorning ? AppColors.primary : Colors.grey.shade600,
                        ),
                        side: BorderSide(
                          color: !_isMorning ? AppColors.primary : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (selected) {
                          if (selected) setState(() => _isMorning = false);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),

                // 4. CHỌN BIỂU TƯỢNG (ICON PICKER)
                const Text(
                  'Chọn biểu tượng hiển thị',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.p8),
                SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _skincareIcons.length,
                    itemBuilder: (context, index) {
                      final item = _skincareIcons[index];
                      final name = item['name']!;
                      final isSelected = _selectedIconName == name;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedIconName = name),
                        child: Container(
                          width: 54,
                          margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Tooltip(
                            message: item['label']!,
                            child: Icon(
                              getIconFromName(name),
                              color: isSelected ? AppColors.primary : Colors.grey.shade600,
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.p24),

                // 5. NÚT XÁC NHẬN VÀ HỦY BỎ
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            controller.addCustomStep(
                              title: _titleController.text.trim(),
                              description: _descController.text.trim(),
                              iconName: _selectedIconName,
                              isMorning: _isMorning,
                            );
                            Get.back(); // Đóng BottomSheet
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Thêm bước',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
