import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:skin_disease_app/core/models/scan_model.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../main/controllers/main_controller.dart';


class HistoryController extends GetxController {
  var historyList = <ScanModel>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'Không tìm thấy key';
  String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_RESET'] ?? 'Không tìm thấy key';
  @override
  void onInit() {
    super.onInit();
    
    // Đăng ký lắng nghe sự thay đổi của currentUserId để tự động cập nhật stream lịch sử
    final AuthController authController = Get.find<AuthController>();
    ever(authController.currentUserId, (String uid) {
      print('🔄 [HistoryController] Nhận thấy UID thay đổi: $uid. Cập nhật lại stream lịch sử...');
      if (uid.isNotEmpty) {
        historyList.bindStream(fetchHistoryStream());
      } else {
        // Khi đăng xuất, xóa toàn bộ danh sách để bảo mật thông tin người dùng cũ
        historyList.clear();
      }
    });

    // Khởi tạo stream ban đầu nếu UID đã sẵn sàng
    if (currentUserId.isNotEmpty) {
      historyList.bindStream(fetchHistoryStream());
    }
    syncPendingScans();
  }

  String get currentUserId {
    return Get.find<AuthController>().currentUserId.value;
  }


  Stream<List<ScanModel>> fetchHistoryStream() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('scan_history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<ScanModel> retVal = [];
      for (var element in query.docs) {
        retVal.add(ScanModel.fromFirestore(element));
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

      final newDocRef = _firestore.collection('users').doc(currentUserId).collection('scan_history').doc();

      ScanModel newRecord = ScanModel(
        id: newDocRef.id,
        userId: currentUserId,
        localImagePath: localImagePath,
        firebaseImageUrl: imagePath, // Dùng link Cloudinary trả về
        diseaseName: diseaseName,
        confidence: confidence,
        date: DateTime.now(),
        isSynced: true
      );
      await newDocRef.set(newRecord.toMap());

      // await _firestore.collection('users').doc(currentUserId).collection('scan_history').add(newRecord.toMap());

      Get.snackbar('Thành công', 'Đã lưu kết quả chẩn đoán',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2A9D8F).withOpacity(0.8), // Xanh lá
          colorText: const Color(0xFFFFFFFF));

    } catch (e) {
      Get.snackbar('Lỗi lưu trữ', 'Có lỗi xảy ra: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> syncSingleScanToCloud(ScanModel localScan) async {
    try {
      print('Bắt đầu đồng bộ ngầm bản ghi: ${localScan.id}...');

      // 1. UPLOAD ẢNH LÊN CLOUDINARY
      String cloudImageUrl = await _uploadImageToCloudinary(localScan.localImagePath);

      if (cloudImageUrl.isEmpty) {
        print('Đồng bộ ngầm thất bại: Không tải được ảnh lên Cloudinary.');
        return; // Dừng lại, giữ nguyên isSynced = false để chờ lần sau đồng bộ lại
      }

      // 2. TẠO BẢN SAO ĐÃ ĐỒNG BỘ (Cập nhật link ảnh và trạng thái)
      ScanModel syncedScan = ScanModel(
        id: localScan.id, // Giữ nguyên ID Local để dễ dàng đè dữ liệu
        userId: localScan.userId,
        localImagePath: localScan.localImagePath,
        firebaseImageUrl: cloudImageUrl, // 💡 Đã có link xịn từ Cloud
        diseaseName: localScan.diseaseName,
        confidence: localScan.confidence,
        date: localScan.date,
        isSynced: true, // 💡 Kích hoạt trạng thái: Đã lên mây!
      );

      // 3. ĐẨY LÊN FIRESTORE
      // Dùng luôn cái ID local làm Document ID trên Firebase để 2 bên đồng nhất
      await _firestore
          .collection('users')
          .doc(syncedScan.userId)
          .collection('scan_history')
          .doc(syncedScan.id)
          .set(syncedScan.toMap());

      // 4. CẬP NHẬT LẠI TRẠNG THÁI XUỐNG ĐIỆN THOẠI (LOCAL DB)
      // Để lần sau mở app lên, hệ thống biết file này không cần đồng bộ nữa
      final localStorage = Get.find<LocalStorageService>();
      await localStorage.saveScan(syncedScan);

      print('Đồng bộ ngầm thành công! ID: ${syncedScan.id}');

    } catch (e) {
      // LƯU Ý KỸ THUẬT: Tuyệt đối KHÔNG dùng Get.snackbar ở đây!
      // Vì đây là tiến trình chạy ngầm, nếu báo lỗi sẽ làm phiền trải nghiệm người dùng.
      // Chỉ in ra console để Dev theo dõi.
      print('Lỗi tiến trình đồng bộ ngầm: $e');
    }
  }

  Future<void> syncPendingScans() async {
    final localStorage = Get.find<LocalStorageService>();

    List<ScanModel> pendingScans = localStorage.getUnsyncedScans();

    if (pendingScans.isEmpty) {
      return;
    }

    for (var scan in pendingScans) {
      await syncSingleScanToCloud(scan);
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
  Future<void> deleteHistoryItem(ScanModel item)  async {
    final String uid = currentUserId; // Hàm get currentUserId ở bước trước

    if (uid.isEmpty) {
      Get.snackbar('Lỗi', 'Không tìm thấy ID người dùng');
      return;
    }

    try {
      Get.defaultDialog(
        title: 'Xác nhận',
        middleText: 'Bạn có chắc chắn muốn xóa không?',
        textConfirm: 'Xóa',
        textCancel: 'Hủy',
        confirmTextColor: const Color(0xFFFFFFFF),
        onConfirm: () async {
          await _firestore.collection('users').doc(uid).collection('scan_history').doc(item.id).delete();
          Get.back();
          Get.snackbar('Đã xóa', 'Bản ghi chẩn đoán đã được xóa khỏi lịch sử.',
              snackPosition: SnackPosition.TOP);
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
      Get.toNamed(Routes.DASHBOARD);
    }
  }
  // Hàm xóa toàn bộ lịch sử
  void clearAllHistory() {
    // Lấy User ID (từ GetStorage hoặc AuthController mà bạn đã thiết lập)
    final String uid = currentUserId;

    if (uid.isEmpty || historyList.isEmpty) return;

    Get.defaultDialog(
      title: 'Xác nhận cảnh báo',
      middleText: 'Bạn có chắc chắn muốn xóa toàn bộ lịch sử chẩn đoán? Hành động này không thể hoàn tác.',
      textConfirm: 'Xóa tất cả',
      textCancel: 'Hủy',
      confirmTextColor: const Color(0xFFFFFFFF),
      buttonColor: Colors.redAccent, // Đổi màu nút thành đỏ để cảnh báo thao tác nguy hiểm
      onConfirm: () async {
        try {
          Get.back();

          var collectionRef = _firestore
              .collection('users')
              .doc(uid)
              .collection('scan_history');

          var snapshots = await collectionRef.get();

          // 2. Khởi tạo WriteBatch để gom lệnh xóa hàng loạt
          var batch = _firestore.batch();

          // 3. Duyệt qua từng bản ghi và đưa lệnh xóa vào Batch
          for (var doc in snapshots.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();

          Get.snackbar(
            'Thành công',
            'Đã xóa toàn bộ lịch sử trên đám mây',
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            'Lỗi',
            'Không thể xóa toàn bộ lịch sử',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
    );
  }
}