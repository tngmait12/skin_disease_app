import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/widgets/products_tab.dart';
import 'package:skin_disease_app/core/widgets/routine_list.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/clinic_map_service.dart';
import '../../../core/widgets/clinic_map.dart';
import '../../reminder/reminder_controller.dart';
import '../controllers/routine_controller.dart';

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
        appBar: AppBar(
          title: const Text('Personalized Skin Routine', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withOpacity(0.25), // Background mờ cho Tab đang chọn
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
                    Icon(Icons.vaccines_rounded, size: 18), // Icon chai lọ dược phẩm
                    SizedBox(width: 6),
                    Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- HEADER: THÔNG TIN BỆNH & TIẾN ĐỘ ---
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tình trạng hiện tại:', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(controller.routine.conditionName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),

                  // NẾU CÓ CẢNH BÁO Y TẾ THÌ HIỂN THỊ KHUNG ĐỎ
                  if (controller.routine.medicalAlert.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
                          const SizedBox(width: 12),
                          Expanded(child: Text(controller.routine.medicalAlert, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13))),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  ClinicMap(),

                  // THANH TIẾN ĐỘ CHĂM SÓC TRONG NGÀY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiến độ hôm nay', style: TextStyle(fontWeight: FontWeight.bold)),
                      Obx(() => Text('${(controller.progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )),
                ],
              ),
            ),

            // --- NỘI DUNG CÁC TAB ---
            Expanded(
              child: TabBarView(
                children: [
                  RoutineList(steps: controller.routine.morningRoutine, completedList: controller.completedMorning, onToggle: controller.toggleMorning, isMorning: true, reminderCtrl: reminderCtrl),
                  RoutineList(steps: controller.routine.eveningRoutine, completedList: controller.completedEvening, onToggle: controller.toggleEvening, isMorning: false, reminderCtrl: reminderCtrl),
                  ProductsTabWidget(routine: controller.routine)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}