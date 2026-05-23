import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/models/routine_model.dart';
import '../../../../core/widgets/clinic_map.dart';
import '../controllers/routine_controller.dart';

class RoutineHeaderCard extends StatelessWidget {
  final RoutineController controller;
  final SkinRoutine skinRoutine;

  const RoutineHeaderCard({
    super.key,
    required this.controller,
    required this.skinRoutine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tình trạng hiện tại:',
            style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            skinRoutine.conditionName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),

          // BỘ LỌC LOẠI DA ĐỘNG (WOW EFFECT!)
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Loại da: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  final skinType = controller.userProfile.value.skinType;
                  final isSensitive = controller.userProfile.value.isSensitive;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          avatar: Icon(
                            Icons.science_outlined,
                            size: 16,
                            color: skinType == 'Oily' ? AppColors.primary : Colors.grey[600],
                          ),
                          label: const Text('Da Dầu'),
                          selected: skinType == 'Oily',
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: skinType == 'Oily' ? AppColors.primary : Colors.grey[600],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onSelected: (selected) {
                            if (selected) {
                              controller.updateSkinProfile('Oily', isSensitive);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: Icon(
                            Icons.water_drop_outlined,
                            size: 16,
                            color: skinType == 'Dry' ? AppColors.primary : Colors.grey[600],
                          ),
                          label: const Text('Da Khô'),
                          selected: skinType == 'Dry',
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: skinType == 'Dry' ? AppColors.primary : Colors.grey[600],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onSelected: (selected) {
                            if (selected) {
                              controller.updateSkinProfile('Dry', isSensitive);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          avatar: Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: isSensitive ? Colors.redAccent : Colors.grey[600],
                          ),
                          label: const Text('Nhạy Cảm'),
                          selected: isSensitive,
                          selectedColor: Colors.redAccent.withOpacity(0.15),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSensitive ? Colors.redAccent : Colors.grey[600],
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onSelected: (selected) {
                            controller.updateSkinProfile(skinType, selected);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),

          // NẾU CÓ CẢNH BÁO Y TẾ THÌ HIỂN THỊ KHUNG ĐỎ
          if (skinRoutine.medicalAlert.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      skinRoutine.medicalAlert,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Bản đồ tìm phòng khám da liễu gần nhất
          ClinicMap(),
          const SizedBox(height: 16),

          // THANH TIẾN ĐỘ CHĂM SÓC TRONG NGÀY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tiến độ hôm nay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Obx(() {
                return Text(
                  '${(controller.progress * 100).toInt()}%',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Obx(() {
              return LinearProgressIndicator(
                value: controller.progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              );
            }),
          ),
        ],
      ),
    );
  }
}
