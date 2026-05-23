import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/custom_camera_controller.dart';

class CustomCameraScreen extends GetView<CustomCameraController> {
  const CustomCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomCameraController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return Stack(
          children: [
            // 1. Camera Preview
            Positioned.fill(
              child: CameraPreview(controller.cameraController),
            ),

            // 2. Lớp Overlay (Khung ngắm)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(color: Colors.transparent),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 280, height: 280,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Viền khung ngắm
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 280, height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Đặt vùng da cần phân tích vào giữa khung hình', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            // 3. Nút điều khiển trên (Đóng & Flash)
            Positioned(
              top: 50, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Get.back(),
                  ),
                  IconButton(
                    icon: Icon(
                        controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white, size: 30
                    ),
                    onPressed: controller.toggleFlash,
                  ),
                ],
              ),
            ),

            // 4. Nút điều khiển dưới (Thư viện, Chụp, Đổi Camera)
            Positioned(
              bottom: 40, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                    onPressed: controller.pickImageFromGallery,
                  ),
                  GestureDetector(
                    onTap: () async {
                      String? path = await controller.takePicture();
                      if (path != null) {
                        Get.toNamed(Routes.REVIEW, arguments: path);
                      }
                    },
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                    onPressed: controller.switchCamera,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}