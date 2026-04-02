import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class ClinicMapService {

  // Hàm tĩnh (static) để có thể gọi ở bất cứ đâu mà không cần khởi tạo
  static Future<void> findNearbyClinics() async {
    // Từ khóa tìm kiếm được mã hóa (chuyển dấu cách thành %20 để URL hiểu được)
    final String query = Uri.encodeComponent("phòng khám da liễu bệnh viện da liễu gần đây");

    // Sử dụng Universal URL chuẩn của Google Maps
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    try {
      // Kiểm tra xem máy có hỗ trợ mở link này không (có app Maps hoặc trình duyệt)
      if (await canLaunchUrl(googleMapsUrl)) {
        // 💡 ĐIỂM ĂN TIỀN LÀ Ở ĐÂY:
        // LaunchMode.externalApplication sẽ ép điện thoại văng ra khỏi app của bạn
        // và mở thẳng app Google Maps xịn xò (nếu có cài) thay vì mở trình duyệt web cùi bắp.
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar(
          'Không thể mở bản đồ',
          'Vui lòng cài đặt Google Maps hoặc kiểm tra lại kết nối mạng.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi hệ thống', 'Đã xảy ra sự cố khi tìm đường: $e');
    }
  }
}