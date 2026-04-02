import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/notification_service.dart';

class ReminderController extends GetxController {
  final _box = GetStorage();
  final _notiService = Get.find<NotificationService>();

  // Biến trạng thái (Observable) để UI tự động cập nhật
  var isMorningOn = false.obs;
  var isEveningOn = false.obs;

  // Mặc định: Sáng 7:00 AM, Tối 20:00 PM
  var morningTime = const TimeOfDay(hour: 7, minute: 0).obs;
  var eveningTime = const TimeOfDay(hour: 20, minute: 0).obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedSettings();
  }

  // 1. Khôi phục cài đặt từ lần mở app trước
  void _loadSavedSettings() {
    isMorningOn.value = _box.read('isMorningOn') ?? false;
    isEveningOn.value = _box.read('isEveningOn') ?? false;

    morningTime.value = TimeOfDay(
      hour: _box.read('morningHour') ?? 7,
      minute: _box.read('morningMinute') ?? 0,
    );
    eveningTime.value = TimeOfDay(
      hour: _box.read('eveningHour') ?? 20,
      minute: _box.read('eveningMinute') ?? 0,
    );
  }

  // 2. Xử lý bật/tắt nhắc nhở Sáng
  Future<void> toggleMorning(bool value) async {
    isMorningOn.value = value;
    _box.write('isMorningOn', value);

    if (value) {
      await _notiService.scheduleDailyRoutine(
        id: 1, // ID 1 cho buổi sáng
        title: 'Đến giờ Skincare Sáng ☀️',
        body: 'Hãy bắt đầu ngày mới bằng việc làm sạch và bôi kem chống nắng nhé!',
        hour: morningTime.value.hour,
        minute: morningTime.value.minute,
      );
      Get.snackbar('Thành công', 'Đã bật nhắc nhở buổi sáng', snackPosition: SnackPosition.BOTTOM);
    } else {
      await _notiService.cancelNotification(1);
    }
  }

  // 3. Xử lý bật/tắt nhắc nhở Tối
  Future<void> toggleEvening(bool value) async {
    isEveningOn.value = value;
    _box.write('isEveningOn', value);

    if (value) {
      await _notiService.scheduleDailyRoutine(
        id: 2, // ID 2 cho buổi tối
        title: 'Đến giờ Skincare Tối 🌙',
        body: 'Đã đến lúc tẩy trang và dưỡng phục hồi da rồi!',
        hour: eveningTime.value.hour,
        minute: eveningTime.value.minute,
      );
      Get.snackbar('Thành công', 'Đã bật nhắc nhở buổi tối', snackPosition: SnackPosition.BOTTOM);
    } else {
      await _notiService.cancelNotification(2);
    }
  }

  // 4. Mở hộp thoại chọn giờ
  Future<void> pickTime(BuildContext context, bool isMorning) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? morningTime.value : eveningTime.value,
    );

    if (picked != null) {
      if (isMorning) {
        morningTime.value = picked;
        _box.write('morningHour', picked.hour);
        _box.write('morningMinute', picked.minute);
        if (isMorningOn.value) toggleMorning(true); // Cập nhật lại báo thức nếu đang bật
      } else {
        eveningTime.value = picked;
        _box.write('eveningHour', picked.hour);
        _box.write('eveningMinute', picked.minute);
        if (isEveningOn.value) toggleEvening(true); // Cập nhật lại báo thức nếu đang bật
      }
    }
  }
}