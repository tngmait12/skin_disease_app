import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  var currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserId();
  }

  void _initializeUserId() {
    // 1. Đọc thử xem trong máy đã có ID chưa
    String? storedUid = box.read('local_user_id');

    if (storedUid != null && storedUid.isNotEmpty) {
      // Nếu có rồi thì lấy ra dùng
      currentUserId.value = storedUid;
      print('Đã tìm thấy User ID cũ: $storedUid');
    } else {
      // 2. Nếu chưa có (Tải app lần đầu), tự tạo ra 1 cái ID duy nhất
      // Dùng thời gian (milliseconds) kết hợp để đảm bảo không ai trùng ai
      String newUid = 'DEVICE_${DateTime.now().millisecondsSinceEpoch}';

      // Lưu vĩnh viễn xuống Local Storage
      box.write('local_user_id', newUid);
      currentUserId.value = newUid;
      print('Đã tạo User ID mới: $newUid');
    }
  }
}