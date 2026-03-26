import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/routine_controller.dart';
import '../models/routine_model.dart';

class RoutineScreen extends StatelessWidget {
  final String diseaseName;

  const RoutineScreen({super.key, required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoutineController(diseaseName: diseaseName));

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
                  _buildRoutineList(controller.routine.morningRoutine, controller.completedMorning, controller.toggleMorning),
                  _buildRoutineList(controller.routine.eveningRoutine, controller.completedEvening, controller.toggleEvening),
                  _buildProductsTab(controller.routine),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Danh sách các bước (Dùng chung cho cả Sáng và Tối)
  Widget _buildRoutineList(List<RoutineStep> steps, RxList<bool> completedList, Function(int) onToggle) {
    if (steps.isEmpty) return const Center(child: Text('Không có hướng dẫn.'));

    return ListView.builder(
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
              side: BorderSide(color: step.isWarning ? Colors.redAccent.withOpacity(0.5) : Colors.transparent, width: 2),
            ),
            child: InkWell(
              onTap: () => onToggle(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon bước làm
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.grey[300] : (step.isWarning ? Colors.red.shade50 : AppColors.primary.withOpacity(0.1)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.icon, color: isDone ? Colors.grey : (step.isWarning ? Colors.redAccent : AppColors.primary)),
                    ),
                    const SizedBox(width: 16),
                    // Nội dung
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              step.title,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDone ? Colors.grey : (step.isWarning ? Colors.redAccent : Colors.black87)
                              )
                          ),
                          const SizedBox(height: 4),
                          Text(step.description, style: TextStyle(color: isDone ? Colors.grey : Colors.black54, fontSize: 13)),
                        ],
                      ),
                    ),
                    // Nút Checkbox
                    Checkbox(
                      value: isDone,
                      onChanged: (val) => onToggle(index),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // Widget: Tab Sản phẩm và Hoạt chất
  Widget _buildProductsTab(SkinRoutine routine) {

    final Color softGreen = Colors.teal.shade600;
    final Color softGreenBg = Colors.teal.shade50;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KHU VỰC 1: NÊN DÙNG (Màu xanh)
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: softGreen, size: 22),
              const SizedBox(width: 8),
              Text('Hoạt chất khuyên dùng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: softGreen)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: routine.recommendIngredients.map((e) => Chip(
              label: Text(e, style: TextStyle(color: softGreen, fontWeight: FontWeight.w600)),
              backgroundColor: softGreenBg,
              side: BorderSide(color: softGreen.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            )).toList(),
          ),
          const SizedBox(height: 24),

          // KHU VỰC 2: TRÁNH DÙNG (Màu đỏ)
          Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 22),
              const SizedBox(width: 8),
              const Text('Tuyệt đối tránh xa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: routine.avoidIngredients.map((e) => Chip(
              label: Text(e, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              backgroundColor: Colors.red.shade50,
              side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            )).toList(),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // KHU VỰC 3: SẢN PHẨM GỢI Ý Y KHOA
          const Row(
            children: [
              Icon(Icons.medication_liquid_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Dược Mỹ Phẩm Gợi Ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 16),

          // Vẽ danh sách sản phẩm (Dựa vào mảng recommendedProducts bạn vừa thêm ở file data)
          ...routine.recommendedProducts.map((product) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.clean_hands, color: AppColors.primary),
              ),
              title: Text(product.category, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(product.brandAndName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(product.reason, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
          )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}