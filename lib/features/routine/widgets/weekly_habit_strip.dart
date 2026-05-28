import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/routine_controller.dart';

class WeeklyHabitStrip extends StatelessWidget {
  const WeeklyHabitStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoutineController>();

    return Obx(() {
      final streak = controller.currentStreak.value;
      final weeklyData = controller.weeklyHistory;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 8),
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. BANNER CHUỖI LIÊN TIẾP (STREAK BANNER)
            if (streak > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9F1C), Color(0xFFFF4000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4000).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Ngọn lửa hoạt động
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chuỗi chăm sóc da: $streak ngày liên tục!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Bạn đang làm rất tốt! Giữ vững ngọn lửa để có làn da rạng rỡ.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Banner hướng dẫn khi streak = 0
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.spa_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hoàn thành 100% tất cả các bước hôm nay để kích hoạt chuỗi Streak chăm sóc da đầu tiên!',
                        style: TextStyle(
                          color: Colors.blueGrey.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 2. DẢI NGÀY TRONG TUẦN (HABIT CALENDAR STRIP)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weeklyData.map((dayItem) {
                final isDone = dayItem.completionRatio >= 0.999;
                final isPartial = dayItem.completionRatio > 0.0 && dayItem.completionRatio < 0.999;
                final isToday = dayItem.isToday;

                return Column(
                  children: [
                    // Nhãn thứ (T2 - CN)
                    Text(
                      dayItem.dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? AppColors.primary : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Vòng tròn trạng thái ngày
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isDone
                            ? const LinearGradient(
                                colors: [Colors.teal, AppColors.success],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isDone ? null : (isPartial ? Colors.teal.shade50 : Colors.grey.shade100),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 2.5)
                            : (isPartial
                                ? Border.all(color: Colors.teal.withOpacity(0.5), width: 1.5)
                                : Border.all(color: Colors.transparent)),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayItem.date.day.toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                                      color: isToday
                                          ? AppColors.primary
                                          : (isPartial ? Colors.teal.shade800 : Colors.black87),
                                    ),
                                  ),
                                  // Hiển thị chấm nhỏ dưới ngày nếu hoàn thành một phần
                                  if (isPartial)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.teal,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}
