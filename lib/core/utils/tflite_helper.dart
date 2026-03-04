import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteHelper {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  // 1. KHỞI TẠO VÀ NẠP MÔ HÌNH
  static Future<void> loadModel() async {
    try {
      // Nạp não bộ (.tflite)
      _interpreter = await Interpreter.fromAsset('assets/models/skin_disease_model.tflite');

      // Nạp từ điển tên bệnh (labels.txt)
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

      print('✅ Đã nạp thành công mô hình và ${_labels?.length} tên bệnh!');
    } catch (e) {
      print('❌ Lỗi khi nạp mô hình: $e');
    }
  }

  // 2. CHẠY SUY LUẬN (INFERENCE) TRÊN ẢNH CHỤP
  static Future<Map<String, dynamic>?> runInference(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      print('Mô hình chưa được nạp!');
      return null;
    }

    // --- TIỀN XỬ LÝ ẢNH (Quan trọng nhất) ---
    // Đọc file ảnh từ điện thoại
    File imageFile = File(imagePath);
    img.Image? rawImage = img.decodeImage(imageFile.readAsBytesSync());
    if (rawImage == null) return null;

    // Resize về đúng 224x224 như lúc huấn luyện
    img.Image resizedImage = img.copyResize(rawImage, width: 224, height: 224);

    // Chuyển ảnh thành mảng Float32List có kích thước [1, 224, 224, 3]
    var input = List.generate(
      1,
          (i) => List.generate(
        224,
            (y) => List.generate(
          224,
              (x) {
            final pixel = resizedImage.getPixel(x, y);
            // Lấy mã màu RGB và chuẩn hóa (chia cho 255.0)
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0
            ];
          },
        ),
      ),
    );

    // --- CHUẨN BỊ ĐẦU RA ---
    // Mảng chứa kết quả 22 loại bệnh [1, 22]
    var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

    // --- BẤM NÚT DỰ ĐOÁN ---
    _interpreter!.run(input, output);

    // --- TÌM KẾT QUẢ CAO NHẤT ---
    List<double> probabilities = output[0];
    double maxConfidence = 0.0;
    int maxIndex = -1;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }

    // Trả về Tên bệnh và Phần trăm tự tin
    return {
      'disease_name': _labels![maxIndex],
      'confidence': (maxConfidence * 100).toStringAsFixed(2), // Làm tròn 2 chữ số thập phân
    };
  }

  // 3. ĐÓNG MÔ HÌNH KHI KHÔNG DÙNG (Chống rò rỉ RAM)
  static void close() {
    _interpreter?.close();
  }
}