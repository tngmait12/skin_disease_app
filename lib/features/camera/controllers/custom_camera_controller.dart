import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../main.dart';
import '../screens/review_screen.dart';


class CustomCameraController extends GetxController {
  late CameraController cameraController;

  var isInitialized = false.obs;
  var isFlashOn = false.obs;
  var isAnalyzing = false.obs;
  var currentCameraIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      Get.snackbar('Lỗi', 'Không tìm thấy camera trên thiết bị');
      return;
    }

    cameraController = CameraController(
      cameras[currentCameraIndex.value],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await cameraController.initialize();
      isInitialized.value = true;
    } catch (e) {
      Get.snackbar('Lỗi Camera', 'Không thể khởi tạo camera: $e');
    }
  }

  Future<void> switchCamera() async {
    isInitialized.value = false;
    currentCameraIndex.value = currentCameraIndex.value == 0 ? 1 : 0;
    await _initCamera();
  }

  Future<void> toggleFlash() async {
    isFlashOn.value = !isFlashOn.value;
    await cameraController.setFlashMode(
      isFlashOn.value ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<String?> takePicture() async {
    if (!cameraController.value.isInitialized) return null;

    try {
      final XFile picture = await cameraController.takePicture();

      if (isFlashOn.value) {
        toggleFlash();
      }
      return picture.path;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chụp ảnh');
      return null;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        if (isFlashOn.value) toggleFlash();

        Get.to(() => ReviewScreen(imagePath: image.path));
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể mở thư viện ảnh: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}