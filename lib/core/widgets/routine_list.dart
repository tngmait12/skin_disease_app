import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/widgets/reminder_card.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/routine_model.dart';
import '../../../core/utils/app_icons.dart';
import '../../features/reminder/reminder_controller.dart'; // Chứa hàm getIconFromName


import '../../features/routine/widgets/add_step_dialog.dart';

class RoutineList extends StatelessWidget {
  final List<RoutineStep> steps;
  final RxList<bool> completedList;
  final Function(int) onToggle;
  final bool isMorning;
  final ReminderController reminderCtrl;
  final Function(int)? onDeleteCustomStep; // Callback xóa bước tự chọn

  const RoutineList({
    super.key,
    required this.steps,
    required this.completedList,
    required this.onToggle,
    required this.isMorning,
    required this.reminderCtrl,
    this.onDeleteCustomStep,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Đăng ký sự phụ thuộc phản xạ (reactive dependency) với GetX để tránh lỗi "improper use of GetX"
      // trong trường hợp steps rỗng hoặc ListView.builder nạp phần tử một cách lười biếng (lazy loading).
      final _ = completedList.length;

      return ListView.builder(
        padding: const EdgeInsets.all(AppSizes.p16),
        itemCount: steps.length + 2, // +1 for ReminderCard, +1 for Add Step button
        itemBuilder: (context, index) {
          // First item is the ReminderCard
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ReminderCard(
                reminderCtrl: reminderCtrl,
                isMorning: isMorning,
              ),
            );
          }

          // Last item is the Add Step button
          if (index == steps.length + 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.bottomSheet(
                    AddStepDialog(initialIsMorning: isMorning),
                    isScrollControlled: true,
                  );
                },
                icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                label: const Text(
                  'Thêm bước chăm sóc tự chọn',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            );
          }

          // Intermediate items are the steps
          final stepIndex = index - 1;
          final step = steps[stepIndex];
          
          // Lấy trực tiếp trạng thái hoàn thành một cách an toàn trong Obx lớn
          bool isDone = completedList[stepIndex];

          return Card(
            elevation: isDone ? 1 : 3,
            margin: const EdgeInsets.only(bottom: 16),
            color: isDone ? Colors.grey[100] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: step.isWarning
                      ? Colors.redAccent.withOpacity(0.5)
                      : Colors.transparent,
                  width: 2),
            ),
            child: InkWell(
              onTap: () => onToggle(stepIndex),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.grey[300]
                            : (step.isWarning
                            ? Colors.red.shade50
                            : AppColors.primary.withOpacity(0.1)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getIconFromName(step.iconName),
                        color: isDone
                            ? Colors.grey
                            : (step.isWarning
                            ? Colors.redAccent
                            : AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isDone
                                        ? Colors.grey
                                        : (step.isWarning
                                            ? Colors.redAccent
                                            : Colors.black87),
                                  ),
                                ),
                              ),
                              if (step.isCustom) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Tự thêm',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step.description,
                            style: TextStyle(
                                color: isDone
                                    ? Colors.grey
                                    : Colors.black54,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (step.isCustom) ...[
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                        tooltip: 'Xóa bước này',
                        onPressed: () => onDeleteCustomStep?.call(stepIndex),
                      ),
                    ],
                    Checkbox(
                      value: isDone,
                      onChanged: (val) => onToggle(stepIndex),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}