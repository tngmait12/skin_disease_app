import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/models/routine_model.dart';

class ProductsTabWidget extends StatelessWidget {
  final SkinRoutine routine;

  const ProductsTabWidget({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
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
              Text('Hoạt chất khuyên dùng:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: softGreen)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: routine.recommendIngredients
                .map((e) => Chip(
              label: Text(e,
                  style: TextStyle(
                      color: softGreen, fontWeight: FontWeight.w600)),
              backgroundColor: softGreenBg,
              side: BorderSide(color: softGreen.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ))
                .toList(),
          ),
          const SizedBox(height: 24),

          // KHU VỰC 2: TRÁNH DÙNG (Màu đỏ)
          Row(
            children: [
              const Icon(Icons.cancel_outlined,
                  color: Colors.redAccent, size: 22),
              const SizedBox(width: 8),
              const Text('Tuyệt đối tránh xa:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: routine.avoidIngredients
                .map((e) => Chip(
              label: Text(e,
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600)),
              backgroundColor: Colors.red.shade50,
              side: BorderSide(
                  color: Colors.redAccent.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ))
                .toList(),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // KHU VỰC 3: SẢN PHẨM GỢI Ý Y KHOA
          const Row(
            children: [
              Icon(Icons.medication_liquid_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Dược Mỹ Phẩm Gợi Ý',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 16),

          // Vẽ danh sách sản phẩm
          ...routine.recommendedProducts.map((product) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.clean_hands,
                    color: AppColors.primary),
              ),
              title: Text(product.category,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(product.brandAndName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(product.reason,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
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