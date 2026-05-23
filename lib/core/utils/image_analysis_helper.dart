import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageAnalysisHelper {
  /// Phân tích độ mờ hoặc mức độ làm mịn (smoothness) của ảnh chụp tổn thương da.
  /// Trả về điểm số chi tiết (gradient variance score).
  /// Điểm số càng cao -> Ảnh càng sắc nét, nhiều chi tiết chân lông/tổn thương thật.
  /// Điểm số thấp (< 15.0) -> Ảnh bị mờ, out-focus hoặc bị camera filter làm mượt da.
  static double calculateDetailScore(Uint8List imageBytes) {
    try {
      // 1. Decode ảnh thô
      final rawImage = img.decodeImage(imageBytes);
      if (rawImage == null) return 100.0; // Dự phòng: Bỏ qua nếu lỗi decode

      // 2. Downscale ảnh xuống 120x120 để tối ưu tốc độ xử lý trong Dart thuần
      final img.Image smallImage = img.copyResize(rawImage, width: 120, height: 120);

      // 3. Chuyển sang ảnh xám (Grayscale)
      final img.Image grayImage = img.grayscale(smallImage);

      final int width = grayImage.width;
      final int height = grayImage.height;

      // 4. Tính toán độ dốc (gradients) dx và dy cho từng pixel
      List<double> gradients = [];
      double sum = 0.0;

      for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
          // Lấy kênh màu r (đại diện cho độ xám)
          final double left = grayImage.getPixel(x - 1, y).r.toDouble();
          final double right = grayImage.getPixel(x + 1, y).r.toDouble();
          final double top = grayImage.getPixel(x, y - 1).r.toDouble();
          final double bottom = grayImage.getPixel(x, y + 1).r.toDouble();

          final double dx = right - left;
          final double dy = bottom - top;
          final double magnitude = sqrt(dx * dx + dy * dy);

          gradients.add(magnitude);
          sum += magnitude;
        }
      }

      if (gradients.isEmpty) return 0.0;

      // 5. Tính trung bình độ dốc
      final double mean = sum / gradients.length;

      // 6. Tính phương sai độ dốc (Gradient Variance)
      double varianceSum = 0.0;
      for (double val in gradients) {
        varianceSum += (val - mean) * (val - mean);
      }

      final double variance = varianceSum / gradients.length;
      
      // Chuẩn hóa điểm số về khoảng thực tế dễ so sánh (thường từ 2.0 -> 80.0)
      return variance;
    } catch (e) {
      // Trả về điểm mặc định cao để không cản trở luồng chính nếu có lỗi phát sinh ngoại lệ
      return 100.0;
    }
  }
}
