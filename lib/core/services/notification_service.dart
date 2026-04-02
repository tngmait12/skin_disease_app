import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    // 1. Khởi tạo múi giờ (Bắt buộc để lên lịch)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh')); // Setup giờ VN

    // 2. Cấu hình icon cho Android (Yêu cầu phải có 1 file ảnh tên là 'ic_launcher' trong thư mục drawable của Android)
    // Tạm thời dùng icon mặc định của app: '@mipmap/ic_launcher'
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình cho iOS (Xin quyền hiển thị thông báo, âm thanh, huy hiệu)
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    return this;
  }

  // ==========================================
  // HÀM LÊN LỊCH NHẮC NHỞ HÀNG NGÀY
  // ==========================================
  Future<void> scheduleDailyRoutine({
    required int id, // ID thông báo (VD: 1 cho Sáng, 2 cho Tối)
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // 1. Gọi hệ thống Android ra làm việc
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // 2. Xin quyền hiển thị pop-up thông báo (Android 13+)
    await androidPlugin?.requestNotificationsPermission();

    // 💡 3. BẮT BUỘC THÊM DÒNG NÀY: Xin quyền "Báo thức và Nhắc nhở" (Android 12+)
    // Dòng này sẽ mở ra 1 màn hình Cài đặt của điện thoại để người dùng bật công tắc cho app của bạn
    await androidPlugin?.requestExactAlarmsPermission();

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'routine_channel_id',
          'Nhắc nhở Chăm sóc da',
          channelDescription: 'Kênh thông báo lịch trình skincare hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Báo thức ngay cả khi máy tắt màn hình ngủ sâu
      //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 💡 Quan trọng: Lặp lại hàng ngày vào ĐÚNG GIỜ NÀY
    );
  }

  // Hàm Hủy nhắc nhở
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> showInstantTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_test_channel',
      'Kênh Test Tức Thì',
      channelDescription: 'Dùng để debug lỗi thông báo',
      importance: Importance.max, // Ép buộc hiển thị pop-up trên màn hình
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      999, // ID test
      '🔔 THÀNH CÔNG RỒI!',
      'Hệ thống thông báo của bạn đã hoạt động hoàn hảo!',
      details,
    );
  }

  // Thuật toán tính toán thời điểm tiếp theo để rung chuông
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Nếu giờ hẹn của ngày hôm nay đã qua mất rồi, thì dời lịch sang ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 💡 THÊM 2 DÒNG NÀY ĐỂ DEBUG:
    print('⏰ [DEBUG BÁO THỨC] Giờ hiện tại của máy: $now');
    print('⏰ [DEBUG BÁO THỨC] Lệnh sẽ rung lúc: $scheduledDate');

    return scheduledDate;
  }
}