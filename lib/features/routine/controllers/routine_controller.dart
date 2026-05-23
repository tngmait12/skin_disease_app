import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/models/routine_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/profile_controller.dart';
import '../../../core/models/user_profile_model.dart';

class DailyHistoryItem {
  final DateTime date;
  final String dayLabel; // VD: "T2", "T3"
  final double completionRatio; // 0.0 -> 1.0
  final bool isToday;

  DailyHistoryItem({
    required this.date,
    required this.dayLabel,
    required this.completionRatio,
    required this.isToday,
  });
}

class RoutineController extends GetxController {
  final String diseaseName;
  final _box = GetStorage();

  // Biến phản xạ lưu trữ phác đồ chăm sóc da của bệnh lý
  final Rxn<SkinRoutine> routine = Rxn<SkinRoutine>();

  // Hồ sơ da phản xạ của người dùng
  final Rx<UserSkinProfile> userProfile = UserSkinProfile(skinType: 'Oily', isSensitive: false).obs;

  // Trạng thái hoàn thành các bước
  var completedMorning = <bool>[].obs;
  var completedEvening = <bool>[].obs;

  // Biến chuỗi ngày hoàn thành (Streak)
  var currentStreak = 0.obs;

  RoutineController({required String? diseaseName}) : diseaseName = diseaseName ?? 'Da khỏe mạnh (Heathy)';

  // Helper định dạng ngày tháng yyyy-MM-dd làm khóa lưu trữ ngày check
  String get _todayStr {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();

    // Lắng nghe thay đổi từ Firestore (qua ProfileController) theo chiều DUY NHẤT:
    // Profile (Firestore) -> RoutineController (local RAM/storage). Không bao giờ ghi ngược lại.
    final ProfileController? profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;
    if (profileCtrl != null) {
      ever(profileCtrl.userProfile, (UserProfileModel? profile) {
        if (profile != null) {
          final String newType = profile.skinType;
          final bool newSensitive = profile.isSensitive;

          // Chỉ cập nhật khi dữ liệu thực sự thay đổi để tránh rebuild thừa
          if (userProfile.value.skinType != newType || userProfile.value.isSensitive != newSensitive) {
            debugPrint('🔄 [RoutineController] Firestore cập nhật loại da: $newType, nhạy cảm: $newSensitive. Đồng bộ local...');
            _updateLocalSkinProfile(newType, newSensitive);
          }
        }
      });
    }

    _loadRoutineStructure();
    _loadDailyProgress();
    _updateStreak();
  }

  /// Cập nhật hồ sơ da THUẦN CỤC BỘ: RAM + GetStorage + tái tạo phác đồ.
  /// Phương thức này KHÔNG giao tiếp với Firestore, tránh tuyệt đối vòng lặp vô tận.
  void _updateLocalSkinProfile(String skinType, bool isSensitive) {
    userProfile.value = UserSkinProfile(skinType: skinType, isSensitive: isSensitive);
    _box.write('user_skin_profile', userProfile.value.toJson());
    _loadRoutineStructure();
    _loadDailyProgress();
  }

  // 0. Tải hồ sơ da (ưu tiên từ ProfileController nếu có)
  void _loadUserProfile() {
    final ProfileController? profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;
    if (profileCtrl != null && profileCtrl.userProfile.value != null) {
      final p = profileCtrl.userProfile.value!;
      userProfile.value = UserSkinProfile(skinType: p.skinType, isSensitive: p.isSensitive);
      return;
    }

    final savedProfile = _box.read('user_skin_profile');
    if (savedProfile != null) {
      try {
        userProfile.value = UserSkinProfile.fromJson(Map<String, dynamic>.from(savedProfile));
      } catch (e) {
        debugPrint('⚠️ Lỗi tải skin profile cũ: $e');
      }
    }
  }

  /// Cập nhật hồ sơ da từ UI (ChoiceChips): Cập nhật local LẬP TỨC để UI phản hồi nhanh,
  /// sau đó đẩy lên Firestore MỘT CHIỀU qua [ProfileController.updateSkinTypeAndSensitivity].
  /// Vòng phản hồi từ Firestore về (ever()) sẽ không kích hoạt lại hàm này vì guard điều kiện.
  void updateSkinProfile(String skinType, bool isSensitive) {
    // Bước 1: Cập nhật cục bộ lập tức (UI phản hồi ngay)
    _updateLocalSkinProfile(skinType, isSensitive);

    // Bước 2: Đẩy đồng bộ lên đám mây một chiều (không chờ kết quả)
    final AuthController? authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (authCtrl != null && !authCtrl.isGuest) {
      final ProfileController? profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;
      if (profileCtrl != null) {
        debugPrint('📤 [RoutineController] Đẩy cập nhật loại da lên Firestore một chiều...');
        profileCtrl.updateSkinTypeAndSensitivity(skinType, isSensitive);
      }
    }
  }

  // 1. Tải cấu trúc phác đồ chăm sóc da (Sinh động kết hợp bước tự chọn cũ nếu có)
  void _loadRoutineStructure() {
    // Luôn sinh động cấu trúc y khoa cơ sở dựa trên Hồ sơ da
    final baseDynamicRoutine = generateDynamicRoutine(diseaseName, userProfile.value);

    // Kiểm tra xem trước đó người dùng có lưu cấu trúc kèm các bước tự chọn không
    final savedRoutineJson = _box.read('routine_structure_$diseaseName');
    if (savedRoutineJson != null) {
      try {
        final savedRoutine = SkinRoutine.fromJson(Map<String, dynamic>.from(savedRoutineJson));
        
        // Trích xuất tất cả các bước do người dùng tự thêm (isCustom = true)
        final customMorningSteps = savedRoutine.morningRoutine.where((s) => s.isCustom).toList();
        final customEveningSteps = savedRoutine.eveningRoutine.where((s) => s.isCustom).toList();

        // Ghép các bước tự chọn vào phác đồ động mới sinh
        baseDynamicRoutine.morningRoutine.addAll(customMorningSteps);
        baseDynamicRoutine.eveningRoutine.addAll(customEveningSteps);
      } catch (e) {
        debugPrint('⚠️ Lỗi phục hồi bước tự chọn cũ: $e');
      }
    }

    routine.value = baseDynamicRoutine;
    _saveRoutineStructure();
  }

  // Tải phác đồ mặc định tinh khiết (Khôi phục)
  void _loadDefaultStructure() {
    routine.value = generateDynamicRoutine(diseaseName, userProfile.value);
    _saveRoutineStructure();
  }

  // Lưu cấu trúc phác đồ chăm sóc da hiện tại
  void _saveRoutineStructure() {
    if (routine.value != null) {
      _box.write('routine_structure_$diseaseName', routine.value!.toJson());
    }
  }

  // 2. Tải tiến trình check hàng ngày (Đọc GetStorage cho ngày hôm nay)
  void _loadDailyProgress() {
    if (routine.value == null) return;

    final savedProgress = _box.read('routine_completion_${diseaseName}_$_todayStr');
    final int morningLen = routine.value!.morningRoutine.length;
    final int eveningLen = routine.value!.eveningRoutine.length;

    if (savedProgress != null) {
      final savedMap = Map<String, dynamic>.from(savedProgress);
      List<bool> storedMorning = List<bool>.from(savedMap['morning'] ?? []);
      List<bool> storedEvening = List<bool>.from(savedMap['evening'] ?? []);

      // Lá chắn an toàn: Đảm bảo độ dài checklist khớp hoàn toàn với số lượng bước hiện có
      if (storedMorning.length < morningLen) {
        storedMorning.addAll(List.generate(morningLen - storedMorning.length, (_) => false));
      } else if (storedMorning.length > morningLen) {
        storedMorning = storedMorning.sublist(0, morningLen);
      }

      if (storedEvening.length < eveningLen) {
        storedEvening.addAll(List.generate(eveningLen - storedEvening.length, (_) => false));
      } else if (storedEvening.length > eveningLen) {
        storedEvening = storedEvening.sublist(0, eveningLen);
      }

      completedMorning.assignAll(storedMorning);
      completedEvening.assignAll(storedEvening);
    } else {
      // Ngày mới chưa có check: Khởi tạo tất cả bằng false
      completedMorning.assignAll(List.generate(morningLen, (_) => false));
      completedEvening.assignAll(List.generate(eveningLen, (_) => false));
      _saveState(); // Lưu trạng thái khởi đầu ngày mới
    }
  }

  // Lưu trạng thái checklist và tiến độ ngày hôm nay
  void _saveState() {
    final savedMap = {
      'morning': completedMorning.toList(),
      'evening': completedEvening.toList(),
    };
    _box.write('routine_completion_${diseaseName}_$_todayStr', savedMap);

    // Lưu tỉ lệ hoàn thành vào lịch sử phục vụ Streak & Habit Strip
    final double currentProgress = progress;
    Map<String, dynamic> history = Map<String, dynamic>.from(_box.read('routine_history_$diseaseName') ?? {});
    history[_todayStr] = currentProgress;
    _box.write('routine_history_$diseaseName', history);

    // Cập nhật lại chuỗi ngày
    _updateStreak();
  }

  // 3. Xử lý tích chọn / hủy tích chọn
  void toggleMorning(int index) {
    if (index >= 0 && index < completedMorning.length) {
      completedMorning[index] = !completedMorning[index];
      _saveState();
    }
  }

  void toggleEvening(int index) {
    if (index >= 0 && index < completedEvening.length) {
      completedEvening[index] = !completedEvening[index];
      _saveState();
    }
  }

  // 4. Các phương thức thêm, xóa, khôi phục bước chăm sóc
  void addCustomStep({
    required String title,
    required String description,
    required String iconName,
    required bool isMorning,
  }) {
    if (routine.value == null) return;

    final newStep = RoutineStep(
      title: title,
      description: description,
      iconName: iconName,
      isWarning: false,
      isCustom: true, // Đánh dấu là bước do người dùng tự thêm
    );

    if (isMorning) {
      routine.value!.morningRoutine.add(newStep);
      completedMorning.add(false);
    } else {
      routine.value!.eveningRoutine.add(newStep);
      completedEvening.add(false);
    }

    routine.refresh(); // Kích hoạt UI vẽ lại
    _saveRoutineStructure();
    _saveState();

    Get.snackbar(
      'Thành công',
      'Đã thêm bước chăm sóc tự chọn mới',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.teal.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void deleteCustomStep(int index, bool isMorning) {
    if (routine.value == null) return;

    if (isMorning) {
      if (index >= 0 && index < routine.value!.morningRoutine.length) {
        routine.value!.morningRoutine.removeAt(index);
        completedMorning.removeAt(index);
      }
    } else {
      if (index >= 0 && index < routine.value!.eveningRoutine.length) {
        routine.value!.eveningRoutine.removeAt(index);
        completedEvening.removeAt(index);
      }
    }

    routine.refresh();
    _saveRoutineStructure();
    _saveState();

    Get.snackbar(
      'Đã xóa',
      'Đã loại bỏ bước chăm sóc khỏi phác đồ',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  // Khôi phục phác đồ gốc của Bác sĩ da liễu
  void resetToDefault() {
    Get.defaultDialog(
      title: 'Khôi phục phác đồ',
      middleText: 'Bạn có chắc chắn muốn xóa toàn bộ các bước tự thêm và khôi phục phác đồ y khoa gốc của bác sĩ không?',
      textConfirm: 'Khôi phục',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back(); // Đóng hộp thoại
        _box.remove('routine_structure_$diseaseName');
        _loadDefaultStructure();
        
        // Reset checklist tiến độ
        completedMorning.assignAll(List.generate(routine.value!.morningRoutine.length, (_) => false));
        completedEvening.assignAll(List.generate(routine.value!.eveningRoutine.length, (_) => false));
        _saveState();

        Get.snackbar(
          'Đã khôi phục',
          'Đã hoàn trả quy trình về phác đồ gốc của bác sĩ da liễu.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      },
    );
  }

  // 5. Getter tính toán tiến độ
  double get progress {
    int total = completedMorning.length + completedEvening.length;
    if (total == 0) return 0;
    int done = completedMorning.where((e) => e).length + completedEvening.where((e) => e).length;
    return done / total;
  }

  // 6. Cập nhật chuỗi ngày hoàn thành (Streak)
  void _updateStreak() {
    Map<String, dynamic> history = Map<String, dynamic>.from(_box.read('routine_history_$diseaseName') ?? {});
    int streak = 0;

    // Xem hôm nay đã đạt 100% (progress >= 1.0) chưa
    bool todayCompleted = (history[_todayStr] ?? 0.0) >= 0.999;
    
    DateTime checkDate = todayCompleted 
        ? DateTime.now() 
        : DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      String dateKey = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      double completion = (history[dateKey] ?? 0.0);
      if (completion >= 0.999) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    currentStreak.value = streak;
  }

  // 7. Sinh dữ liệu tuần phục vụ vẽ Habit Strip (7 ngày qua gồm cả hôm nay)
  List<DailyHistoryItem> get weeklyHistory {
    Map<String, dynamic> history = Map<String, dynamic>.from(_box.read('routine_history_$diseaseName') ?? {});
    List<DailyHistoryItem> items = [];
    
    final List<String> dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    
    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      double completion = (history[dateKey] ?? 0.0);
      
      String label = dayLabels[date.weekday - 1];
      
      items.add(DailyHistoryItem(
        date: date,
        dayLabel: label,
        completionRatio: completion,
        isToday: i == 0,
      ));
    }
    return items;
  }
}