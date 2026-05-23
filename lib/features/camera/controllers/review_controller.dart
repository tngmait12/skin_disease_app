import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import '../../../core/utils/image_analysis_helper.dart';
import '../../home/controllers/home_controller.dart';

class ReviewController extends GetxController {
  final GlobalKey cropKey = GlobalKey();
  var isProcessing = false.obs;

  // Tọa độ X, Y của khung lưới 224x224
  var cropX = 0.0.obs;
  var cropY = 0.0.obs;
  var isInitialized = false.obs;

  // Kích thước hiển thị thực tế của widget ảnh trên màn hình
  double imageDisplayWidth = 0.0;
  double imageDisplayHeight = 0.0;

  // Đặt khung lưới vào giữa màn hình ở lần đầu tiên load ảnh
  void initPosition(double maxWidth, double maxHeight) {
    imageDisplayWidth = maxWidth;
    imageDisplayHeight = maxHeight;
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

  Future<void> confirmAndCropImage({
    required String originalImagePath,
  }) async {
    isProcessing.value = true;
    try {
      // 1. Lưu các thông số cần thiết để truyền vào Isolate
      final double cropXVal = cropX.value;
      final double cropYVal = cropY.value;
      final double screenWidth = imageDisplayWidth;
      final double screenHeight = imageDisplayHeight;

      // 2. Chạy tác vụ cắt ảnh nặng trong Isolate phụ
      final Uint8List pngBytes = await Isolate.run(() async {
        final File file = File(originalImagePath);
        if (!file.existsSync()) {
          throw Exception('Tệp ảnh gốc không tồn tại: $originalImagePath');
        }

        final Uint8List bytes = file.readAsBytesSync();
        final img.Image? originalImage = img.decodeImage(bytes);
        if (originalImage == null) {
          throw Exception('Không thể decode tệp ảnh gốc!');
        }

        final double originalWidth = originalImage.width.toDouble();
        final double originalHeight = originalImage.height.toDouble();

        // Thuật toán quy đổi hình học BoxFit.cover:
        double scale = 1.0;
        double leftOffset = 0.0;
        double topOffset = 0.0;

        final double imageAspect = originalWidth / originalHeight;
        final double screenAspect = screenWidth / screenHeight;

        if (imageAspect > screenAspect) {
          // Ảnh rộng hơn khung hiển thị -> dãn theo chiều cao
          scale = screenHeight / originalHeight;
          double displayedWidth = originalWidth * scale;
          leftOffset = (displayedWidth - screenWidth) / 2;
        } else {
          // Ảnh cao hơn khung hiển thị -> dãn theo chiều rộng
          scale = screenWidth / originalWidth;
          double displayedHeight = originalHeight * scale;
          topOffset = (displayedHeight - screenHeight) / 2;
        }

        // Quy đổi tọa độ từ màn hình về ảnh gốc
        int originalCropX = ((cropXVal + leftOffset) / scale).round();
        int originalCropY = ((cropYVal + topOffset) / scale).round();
        int originalCropSize = (224 / scale).round();

        // Lớp an toàn: Đảm bảo tọa độ cắt không vượt ra ngoài biên ảnh gốc
        if (originalCropX < 0) originalCropX = 0;
        if (originalCropY < 0) originalCropY = 0;
        if (originalCropX + originalCropSize > originalImage.width) {
          originalCropSize = originalImage.width - originalCropX;
        }
        if (originalCropY + originalCropSize > originalImage.height) {
          originalCropSize = originalImage.height - originalCropY;
        }

        // Thực hiện cắt trực tiếp trên ảnh gốc độ phân giải cao
        img.Image cropped = img.copyCrop(
          originalImage,
          x: originalCropX,
          y: originalCropY,
          width: originalCropSize,
          height: originalCropSize,
        );

        // Resize sắc nét về kích thước chuẩn 224x224
        img.Image finalResized = img.copyResize(cropped, width: 224, height: 224);

        // Mã hóa về dạng PNG để lưu và chạy AI
        return Uint8List.fromList(img.encodePng(finalResized));
      });

      // 3. Kiểm tra độ mờ / làm mịn ảnh
      double detailScore = ImageAnalysisHelper.calculateDetailScore(pngBytes);
      debugPrint('📸 [ImageAnalysis] Điểm chi tiết ảnh crop chất lượng cao: $detailScore');

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
      debugPrint('❌ Lỗi cắt ảnh gốc: $e');
      Get.snackbar('Lỗi', 'Không thể cắt ảnh từ file gốc, vui lòng thử lại!');
    } finally {
      isProcessing.value = false;
    }
  }
}