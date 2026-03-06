import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/features/dashboard/screens/dashboard_screen.dart';
import '../../main/controllers/main_controller.dart';
import '../models/history_model.dart';


class HistoryController extends GetxController {
  var historyList = <HistoryModel>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String cloudName = 'dlr3vexho';
  final String uploadPreset = 'dnqiqou6';
  @override
  void onInit() {
    super.onInit();
    historyList.bindStream(fetchHistoryStream());
  }

  Stream<List<HistoryModel>> fetchHistoryStream() {
    return _firestore
        .collection('scan_history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<HistoryModel> retVal = [];
      for (var element in query.docs) {
        retVal.add(HistoryModel.fromFirestore(element));
      }
      return retVal;
    });
  }
  // HÀM LƯU KẾT QUẢ (Dùng Cloudinary + Firestore)
  Future<void> saveDiagnosisResult({
    required String localImagePath,
    required String diseaseName,
    required double confidence,
  }) async {
    try {
      // 1. UPLOAD ẢNH LÊN CLOUDINARY
      String imagePath = await _uploadImageToCloudinary(localImagePath);

      if (imagePath.isEmpty) {
        Get.snackbar('Lỗi', 'Không thể tải ảnh lên máy chủ', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // 2. LƯU DỮ LIỆU VÀO FIRESTORE
      HistoryModel newRecord = HistoryModel(
        imagePath: imagePath, // Dùng link Cloudinary trả về
        diseaseName: diseaseName,
        confidence: confidence,
        date: DateTime.now(),
      );

      await _firestore.collection('scan_history').add(newRecord.toMap());

      Get.snackbar('Thành công', 'Đã lưu kết quả chẩn đoán',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2A9D8F).withOpacity(0.8), // Xanh lá
          colorText: const Color(0xFFFFFFFF));

    } catch (e) {
      Get.snackbar('Lỗi lưu trữ', 'Có lỗi xảy ra: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // HÀM GỌI API CLOUDINARY ĐỂ UP ẢNH
  Future<String> _uploadImageToCloudinary(String imagePath) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        return jsonMap['secure_url']; // Trả về link ảnh bảo mật (https)
      } else {
        print('Cloudinary Error: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Cloudinary Upload Exception: $e');
      return '';
    }
  }

  // HÀM XÓA BẢN GHI (Bây giờ chỉ cần xóa Data trên Firestore)
  Future<void> deleteHistoryItem(HistoryModel item)  async {
    try {
      Get.defaultDialog(
        title: 'Xác nhận',
        middleText: 'Bạn có chắc chắn muốn xóa không?',
        textConfirm: 'Xóa',
        textCancel: 'Hủy',
        confirmTextColor: const Color(0xFFFFFFFF),
        onConfirm: () async {
          await _firestore.collection('scan_history').doc(item.id).delete();
          Get.back();
          Get.snackbar('Đã xóa', 'Bản ghi chẩn đoán đã được xóa khỏi lịch sử.',
              snackPosition: SnackPosition.BOTTOM);
        },
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa bản ghi này', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void goToDashboard() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().changeTab(2);
    } else {
      Get.to(() => const DashboardScreen());
    }
  }

  // Hàm load dữ liệu (Tạm thời dùng Mock Data để test UI)
  void fetchHistory() {
    // TODO: Sau này sẽ đổi thành load từ SQLite hoặc Local Storage
    historyList.assignAll([
      HistoryModel(
        id: '1',
        imagePath: '', // Trống để hiển thị icon mặc định tạm thời
        diseaseName: 'Melanoma (Khối u ác tính)',
        confidence: 0.88,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HistoryModel(
        id: '2',
        imagePath: '',
        diseaseName: 'Acne (Mụn trứng cá)',
        confidence: 0.95,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      HistoryModel(
        id: '3',
        imagePath: '',
        diseaseName: 'Không xác định rõ',
        confidence: 0.45,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HistoryModel(
        id: '4',
        imagePath: '', // Trống để hiển thị icon mặc định tạm thời
        diseaseName: 'Melanoma (Khối u ác tính)',
        confidence: 0.88,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HistoryModel(
        id: '5',
        imagePath: '',
        diseaseName: 'Acne (Mụn trứng cá)',
        confidence: 0.95,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      HistoryModel(
        id: '6',
        imagePath: '',
        diseaseName: 'Không xác định rõ',
        confidence: 0.45,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HistoryModel(
        id: '7',
        imagePath: '', // Trống để hiển thị icon mặc định tạm thời
        diseaseName: 'Melanoma (Khối u ác tính)',
        confidence: 0.88,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HistoryModel(
        id: '8',
        imagePath: '',
        diseaseName: 'Acne (Mụn trứng cá)',
        confidence: 0.95,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      HistoryModel(
        id: '9',
        imagePath: '',
        diseaseName: 'Không xác định rõ',
        confidence: 0.45,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  // Hàm xóa toàn bộ lịch sử
  void clearAllHistory() {
    if (historyList.isEmpty) return;

    Get.defaultDialog(
      title: 'Xác nhận',
      middleText: 'Bạn có chắc chắn muốn xóa toàn bộ lịch sử chẩn đoán?',
      textConfirm: 'Xóa',
      textCancel: 'Hủy',
      confirmTextColor: const Color(0xFFFFFFFF),
      onConfirm: () {
        historyList.clear();
        Get.back(); // Đóng dialog
        Get.snackbar('Thành công', 'Đã xóa toàn bộ lịch sử');
      },
    );
  }
}