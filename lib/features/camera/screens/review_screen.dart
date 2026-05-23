import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';

class ReviewScreen extends StatelessWidget {
  final String imagePath;
  const ReviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Di chuyển khung cắt', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Dùng tay di chuyển khung lưới 224x224 vào đúng vị trí vùng da bạn muốn AI phân tích.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Khởi tạo tọa độ khung lưới nằm giữa màn hình
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.initPosition(constraints.maxWidth, constraints.maxHeight);
                  });

                  return Stack(
                    children: [
                      // LỚP 1: ẢNH GỐC
                      SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // LỚP 2: KHUNG CẮT 224x224
                      Obx(() => Positioned(
                        left: controller.cropX.value,
                        top: controller.cropY.value,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            controller.updatePosition(
                                details.delta.dx,
                                details.delta.dy,
                                constraints.maxWidth,
                                constraints.maxHeight
                            );
                          },

                          child: SizedBox(
                            width: 224,
                            height: 224,
                            child: Stack(
                              children: [
                                // 1. LỚP HIỂN THỊ VÙNG CHỌN:
                                SizedBox(
                                  width: 224,
                                  height: 224,
                                  child: ClipRect(
                                    child: OverflowBox(
                                      maxWidth: constraints.maxWidth,
                                      maxHeight: constraints.maxHeight,
                                      alignment: Alignment.topLeft,
                                      child: Transform.translate(
                                        offset: Offset(-controller.cropX.value, -controller.cropY.value),
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          height: constraints.maxHeight,
                                          child: Image.file(
                                            File(imagePath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // 2. LỚP LƯỚI & VIỀN:
                                IgnorePointer(
                                  child: Container(
                                    width: 224,
                                    height: 224,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.greenAccent, width: 2),
                                    ),
                                    child: CustomPaint(
                                      size: const Size(224, 224),
                                      painter: GridPainter(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  );
                },
              ),
            ),

            // KHOANG NÚT BẤM
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() {
                if (controller.isProcessing.value) {
                  return const CircularProgressIndicator(color: Colors.greenAccent);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Chụp lại', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.confirmAndCropImage(
                        originalImagePath: imagePath,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[700],
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: const Icon(Icons.check, color: Colors.black),
                      label: const Text('Xác nhận', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

// Lớp vẽ Khung lưới 3x3
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}