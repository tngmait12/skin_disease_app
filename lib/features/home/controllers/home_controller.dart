import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/scan_model.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/tflite_helper.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../main/controllers/main_controller.dart';

class HomeController extends GetxController {
  var selectedImagePath = ''.obs;
  var isLoading = false.obs;

  var diseaseName = ''.obs;
  var confidence = ''.obs;
  final Rxn<ScanModel> latestScan = Rxn<ScanModel>();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;

        diseaseName.value = '';
        confidence.value = '';
        latestScan.value = null;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearImage() {
    selectedImagePath.value = '';
    diseaseName.value = '';
    confidence.value = '';
    latestScan.value = null;
  }

  Future<void> analyzeImage() async {
    if (selectedImagePath.value.isEmpty) return;
    if (isLoading.value) return;
    isLoading.value = true;
    latestScan.value = null;

    try {
      final result = await TFLiteHelper.runInference(selectedImagePath.value);

      if (result != null) {
        diseaseName.value = result['disease_name'] ?? 'Không xác định';
        // confidence.value = result['confidence'] ?? '0.00';
        double conf = double.tryParse(result['confidence'].toString()) ?? 0.0;
        confidence.value = conf.toStringAsFixed(2);

        String tempId = DateTime.now().millisecondsSinceEpoch.toString();
        String currentUserId = Get.find<AuthController>().currentUserId.value;

         ScanModel newScan = ScanModel(
          id: tempId,
          userId: currentUserId,
          localImagePath: selectedImagePath.value,
          diseaseName: diseaseName.value,
          confidence: conf,
          date: DateTime.now(),
          isSynced: false,
        );

        final localStorage = Get.find<LocalStorageService>();
        await localStorage.saveScan(newScan);

        latestScan.value = newScan;

        final historyCtrl = Get.isRegistered<HistoryController>()
            ? Get.find<HistoryController>()
            : Get.put(HistoryController());
        historyCtrl.syncSingleScanToCloud(newScan);
        // await historyCtrl.saveDiagnosisResult(
        //   localImagePath: selectedImagePath.value,
        //   diseaseName: diseaseName.value,
        //   confidence: conf,
        // );
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
      Get.toNamed(Routes.HISTORY);
    }
  }
}