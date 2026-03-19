import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/tflite_helper.dart';
import '../../history/controllers/history_controller.dart';
import '../../history/screens/history_screen.dart';
import '../../main/controllers/main_controller.dart';

class HomeController extends GetxController {
  var selectedImagePath = ''.obs;
  var isLoading = false.obs;

  var diseaseName = ''.obs;
  var confidence = ''.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;

        diseaseName.value = '';
        confidence.value = '';
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearImage() {
    selectedImagePath.value = '';
    diseaseName.value = '';
    confidence.value = '';
  }

  Future<void> analyzeImage() async {
    if (selectedImagePath.value.isEmpty) return;
    isLoading.value = true;

    try {
      final result = await TFLiteHelper.runInference(selectedImagePath.value);

      if (result != null) {
        diseaseName.value = result['disease_name'] ?? 'Không xác định';
        // confidence.value = result['confidence'] ?? '0.00';
        double conf = double.tryParse(result['confidence'].toString()) ?? 0.0;
        confidence.value = conf.toStringAsFixed(2);

        final historyCtrl = Get.put(HistoryController());
        await historyCtrl.saveDiagnosisResult(
          localImagePath: selectedImagePath.value,
          diseaseName: diseaseName.value,
          confidence: conf,
        );
      } else {
        Get.snackbar('Lỗi', 'AI không thể phân tích ảnh này.', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void goToHistory() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(1);
    } else {
      Get.to(() => HistoryScreen());
    }
  }
}