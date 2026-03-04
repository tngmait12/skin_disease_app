import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/tflite_helper.dart';

class HomeController extends GetxController {
  // Các biến State được theo dõi bằng .obs (Observable)
  var selectedImagePath = ''.obs;
  var isLoading = false.obs;
  var diseaseName = ''.obs;
  var confidence = ''.obs;

  final ImagePicker _picker = ImagePicker();

  // Hàm gọi Camera hoặc Thư viện ảnh
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;
        // Xóa kết quả cũ khi chọn ảnh mới
        diseaseName.value = '';
        confidence.value = '';

        // Tiến hành phân tích ảnh ngay lập tức
        await analyzeImage(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Hàm gọi AI phán đoán
  Future<void> analyzeImage(String imagePath) async {
    isLoading.value = true; // Bật vòng xoay loading

    try {
      final result = await TFLiteHelper.runInference(imagePath);

      if (result != null) {
        diseaseName.value = result['disease_name'] ?? 'Không xác định';
        confidence.value = result['confidence'] ?? '0.00';
      } else {
        Get.snackbar('Lỗi', 'AI không thể phân tích ảnh này.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false; // Tắt vòng xoay loading
    }
  }
}