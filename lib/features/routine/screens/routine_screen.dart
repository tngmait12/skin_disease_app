import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/widgets/products_tab.dart';
import 'package:skin_disease_app/core/widgets/routine_list.dart';
import '../../../core/constants/app_colors.dart';
import '../../reminder/reminder_controller.dart';
import '../controllers/routine_controller.dart';
import '../widgets/weekly_habit_strip.dart';
import '../widgets/routine_header_card.dart';

class RoutineScreen extends StatelessWidget {
  final String diseaseName;

  const RoutineScreen({super.key, required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoutineController(diseaseName: diseaseName));
    final reminderCtrl = Get.put(ReminderController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Obx(() {
          // Lá chắn bảo vệ khi dữ liệu chưa được nạp
          if (controller.routine.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final skinRoutine = controller.routine.value!;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 1. SliverAppBar ghim cố định tiêu đề và các nút chức năng
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  centerTitle: true,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title: const Text(
                    'Personalized Skin Routine',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  actions: [
                    // Nút Đặt lại phác đồ gốc của Bác sĩ da liễu
                    IconButton(
                      icon: const Icon(Icons.restart_alt_rounded, size: 24),
                      tooltip: 'Khôi phục phác đồ gốc',
                      onPressed: () {
                        controller.resetToDefault();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // 2. SliverToBoxAdapter chứa thẻ thông tin tình trạng, bộ lọc loại da, clinic map & tiến độ
                SliverToBoxAdapter(
                  child: RoutineHeaderCard(
                    controller: controller,
                    skinRoutine: skinRoutine,
                  ),
                ),

                // 3. SliverToBoxAdapter chứa Biểu đồ chuỗi thói quen (Habit Strip)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: WeeklyHabitStrip(),
                  ),
                ),

                // 4. SliverPersistentHeader ghim cố định TabBar khi cuộn qua nó
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    tabBar: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white.withOpacity(0.25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wb_sunny_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Sáng', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.nightlight_round, size: 18),
                              SizedBox(width: 6),
                              Text('Tối', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.vaccines_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                RoutineList(
                  steps: skinRoutine.morningRoutine,
                  completedList: controller.completedMorning,
                  onToggle: controller.toggleMorning,
                  isMorning: true,
                  reminderCtrl: reminderCtrl,
                ),
                RoutineList(
                  steps: skinRoutine.eveningRoutine,
                  completedList: controller.completedEvening,
                  onToggle: controller.toggleEvening,
                  isMorning: false,
                  reminderCtrl: reminderCtrl,
                ),
                ProductsTabWidget(routine: skinRoutine),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate({
    required this.tabBar,
    required this.backgroundColor,
  });

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}