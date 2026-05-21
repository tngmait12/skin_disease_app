import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_disease_app/core/models/chat_message_model.dart';
import 'package:skin_disease_app/features/auth/controllers/auth_controller.dart';
import '../models/scan_model.dart';


class LocalStorageService extends GetxService {
  final GetStorage _box = GetStorage();

  static const String _scansKey = 'scan_history';
  static const String _chatKey = 'chat_history';
  static const String _userKey = 'user_profile';
  static const String _tipsKey = 'saved_tips';

  // Hàm helper để lấy khóa động dựa trên UID của user hiện tại
  String _getKey(String baseKey) {
    try {
      final String uid = Get.find<AuthController>().currentUserId.value;
      if (uid.isNotEmpty) {
        return '${baseKey}_$uid';
      }
    } catch (_) {}
    return '${baseKey}_guest';
  }

  // ==========================================
  // MODULE: LỊCH SỬ QUÉT (SCAN MODEL)
  // ==========================================

  // 1. Đọc toàn bộ danh sách lịch sử
  List<ScanModel> getScans() {
    // Đọc data từ hộp ra (dạng List<dynamic>), nếu null thì trả về mảng rỗng []
    List<dynamic> rawData = _box.read<List<dynamic>>(_getKey(_scansKey)) ?? [];

    // Ánh xạ từ JSON Map sang Object ScanModel
    return rawData.map((e) => ScanModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // 2. Lưu hoặc Cập nhật 1 bản ghi
  Future<void> saveScan(ScanModel scan) async {
    List<ScanModel> currentScans = getScans();

    // Kiểm tra xem ID này đã tồn tại chưa (Dùng khi cập nhật trạng thái isSynced = true)
    int index = currentScans.indexWhere((element) => element.id == scan.id);

    if (index != -1) {
      currentScans[index] = scan;
    } else {
      currentScans.insert(0, scan);
    }

    // Biến toàn bộ mảng Object thành mảng JSON và cất vào hộp
    List<Map<String, dynamic>> jsonData = currentScans.map((e) => e.toJson()).toList();
    await _box.write(_getKey(_scansKey), jsonData);
  }

  // 3. Xóa 1 bản ghi
  Future<void> deleteScan(String id) async {
    List<ScanModel> currentScans = getScans();
    currentScans.removeWhere((element) => element.id == id);

    List<Map<String, dynamic>> jsonData = currentScans.map((e) => e.toJson()).toList();
    await _box.write(_getKey(_scansKey), jsonData);
  }

  // 4. Lọc ra các bản ghi CHƯA ĐỒNG BỘ (isSynced == false)
  List<ScanModel> getUnsyncedScans() {
    List<ScanModel> allScans = getScans();
    return allScans.where((scan) => scan.isSynced == false).toList();
  }

  // ==========================================
  // MODULE: LỊCH SỬ CHAT (CHAT MESSAGE)
  // ==========================================

  List<ChatMessageModel> getChatHistory() {
    List<dynamic> rawData = _box.read<List<dynamic>>(_getKey(_chatKey)) ?? [];
    return rawData.map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveChatHistory(List<ChatMessageModel> messages) async {
    List<Map<String, dynamic>> jsonData = messages.map((e) => e.toJson()).toList();
    await _box.write(_getKey(_chatKey), jsonData);
  }

  // ==========================================
  // MODULE: SỔ TAY DA LIỄU (SAVED TIPS)
  // ==========================================
  List<Map<String, dynamic>> getSavedTips() {
    List<dynamic> rawData = _box.read<List<dynamic>>(_getKey(_tipsKey)) ?? [];
    return rawData.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveSavedTips(List<Map<String, dynamic>> tips) async {
    await _box.write(_getKey(_tipsKey), tips);
  }

  // ==========================================
  // HÀM DỌN DẸP KHẨN CẤP (ĐĂNG XUẤT)
  // ==========================================
  
  // Xóa sạch dữ liệu cục bộ của một User cụ thể (đặc biệt hữu ích khi dọn dẹp Guest khi đăng xuất)
  Future<void> clearUserData(String uid) async {
    if (uid.isEmpty) return;
    await _box.remove('${_chatKey}_$uid');
    await _box.remove('${_tipsKey}_$uid');
    await _box.remove('${_scansKey}_$uid');
  }

  Future<void> clearAllData() async {
    await _box.erase(); // Xóa sạch sành sanh dữ liệu trong điện thoại
  }
}