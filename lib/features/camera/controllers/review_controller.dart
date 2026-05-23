import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/image_analysis_helper.dart';
import '../../home/controllers/home_controller.dart';

class ReviewController extends GetxController {
  final GlobalKey cropKey = GlobalKey();
  var isProcessing = false.obs;

  // Tọa độ X, Y của khung lưới 224x224
  var cropX = 0.0.obs;
  var cropY = 0.0.obs;
  var isInitialized = false.obs;

  // Đặt khung lưới vào giữa màn hình ở lần đầu tiên load ảnh
  void initPosition(double maxWidth, double maxHeight) {
    if (!isInitialized.value) {
      cropX.value = (maxWidth - 224) / 2;
      cropY.value = (maxHeight - 224) / 2;
      isInitialized.value = true;
    }
  }

  // Cập nhật tọa độ khi người dùng vuốt tay kéo khung
  void updatePosition(double dx, double dy, double maxWidth, double maxHeight) {
    double newX = cropX.value + dx;
    double newY = cropY.value + dy;

    // Giới hạn (Clamp) không cho khung lưới chạy lố ra ngoài viền ảnh
    if (newX < 0) newX = 0;
    if (newX > maxWidth - 224) newX = maxWidth - 224;
    if (newY < 0) newY = 0;
    if (newY > maxHeight - 224) newY = maxHeight - 224;

    cropX.value = newX;
    cropY.value = newY;
  }

  Future<void> confirmAndCropImage() async {
    isProcessing.value = true;
    try {
      // Chụp lại đúng cái khung chứa RepaintBoundary
      RenderRepaintBoundary boundary = cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Kiểm tra độ mờ / làm mịn ảnh
      double detailScore = ImageAnalysisHelper.calculateDetailScore(pngBytes);
      debugPrint('📸 [ImageAnalysis] Điểm chi tiết ảnh crop: $detailScore');

      if (detailScore < 15.0) {
        bool? proceed = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                SizedBox(width: 8),
                Text('Ảnh bị mờ hoặc mượt hóa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: const Text(
              'AI phát hiện bức ảnh này bị mờ hoặc có dấu hiệu bị làm mịn da bằng filter. Điều này có thể làm giảm đáng kể độ chính xác của chẩn đoán.\n\nBạn có muốn chụp lại ảnh mới sắc nét hơn dưới ánh sáng tự nhiên không?',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: true), // Vẫn phân tích
                child: const Text('Vẫn phân tích', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: false), // Chụp lại
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Chụp lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (proceed != true) {
          // Người dùng muốn chụp lại -> dừng tiến trình để họ kéo lại hoặc chụp lại
          return;
        }
      }

      final tempDir = Directory.systemTemp;
      final file = await File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      final homeController = Get.find<HomeController>();
      homeController.selectedImagePath.value = file.path;

      Get.until((route) => route.isFirst);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cắt ảnh, vui lòng thử lại!');
    } finally {
      isProcessing.value = false;
    }
  }
}