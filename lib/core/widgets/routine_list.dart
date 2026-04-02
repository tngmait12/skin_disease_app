import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/widgets/reminder_card.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/routine_model.dart';
import '../../../core/utils/app_icons.dart';
import '../../features/reminder/reminder_controller.dart'; // Chứa hàm getIconFromName


class RoutineList extends StatelessWidget {
  final List<RoutineStep> steps;
  final RxList<bool> completedList;
  final Function(int) onToggle;
  final bool isMorning;
  final ReminderController reminderCtrl;

  const RoutineList({
    super.key,
    required this.steps,
    required this.completedList,
    required this.onToggle,
    required this.isMorning,
    required this.reminderCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ReminderCard(
            reminderCtrl: reminderCtrl,
            isMorning: isMorning,
          ),
        ),

        Expanded(
          child: steps.isEmpty
              ? const Center(child: Text('Không có hướng dẫn.'))
              : ListView.builder(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Obx(() {
                bool isDone = completedList[index];
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
                    onTap: () => onToggle(index),
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
                                Text(
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
                          Checkbox(
                            value: isDone,
                            onChanged: (val) => onToggle(index),
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}