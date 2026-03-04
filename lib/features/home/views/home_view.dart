import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);

  // Khởi tạo Controller
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chẩn Đoán Da Liễu AI', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. KHU VỰC HIỂN THỊ ẢNH
              Obx(() => Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: controller.selectedImagePath.value == ''
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Chưa có ảnh nào được chọn', style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(controller.selectedImagePath.value),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
              const SizedBox(height: 24),

              // 2. KHU VỰC NÚT BẤM (CAMERA / GALLERY)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp ảnh', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Thư viện', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 3. KHU VỰC KẾT QUẢ TỪ AI
              Obx(() {
                // Đang xử lý
                if (controller.isLoading.value) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 10),
                      Text('AI đang phân tích...', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500)),
                    ],
                  );
                }

                // Có kết quả
                if (controller.diseaseName.value.isNotEmpty) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.teal[50],
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text('KẾT QUẢ CHẨN ĐOÁN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                          const Divider(color: Colors.teal),
                          const SizedBox(height: 10),
                          Text(
                            controller.diseaseName.value,
                            style: const TextStyle(fontSize: 24, color: Colors.redAccent, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Độ tin cậy: ${controller.confidence.value}%',
                            style: const TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                          const SizedBox(height: 15),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lưu ý: Kết quả từ AI chỉ mang tính chất tham khảo. Vui lòng thăm khám bác sĩ chuyên khoa để có chẩn đoán chính xác nhất.',
                                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }

                // Trạng thái chờ
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}