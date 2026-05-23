import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/models/user_profile_model.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  // Biến quan sát chứa thông tin hồ sơ cá nhân
  final Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi của currentUserId để tự động cập nhật hoặc hủy luồng dữ liệu
    ever(_authController.currentUserId, (String uid) {
      debugPrint('🔄 [ProfileController] Nhận thấy UID thay đổi: $uid. Cập nhật lại kết nối Firestore...');
      _profileSubscription?.cancel();
      _profileSubscription = null;
      userProfile.value = null;

      if (uid.isNotEmpty && !_authController.isGuest) {
        _listenToUserProfile(uid);
      }
    });

    if (_authController.currentUserId.isNotEmpty && !_authController.isGuest) {
      _listenToUserProfile(_authController.currentUserId.value);
    }
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }

  // Lắng nghe dữ liệu profile thời gian thực từ Firestore
  void _listenToUserProfile(String uid) {
    _profileSubscription?.cancel();
    _profileSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot doc) async {
      if (!doc.exists) {
        // Cơ chế Tự Phục Hồi (Self-Healing): Tạo profile mặc định nếu chưa tồn tại
        debugPrint('🔧 [ProfileController] Tài liệu profile không tồn tại cho UID: $uid. Đang khởi tạo tự động...');
        final defaultProfile = UserProfileModel(
          uid: uid,
          email: _authController.userEmail,
          fullName: 'Thành viên SkinShield',
          phoneNumber: '',
          dob: '',
          gender: 'Chưa xác định',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        try {
          await _firestore.collection('users').doc(uid).set(defaultProfile.toMap());
          userProfile.value = defaultProfile;
        } catch (e) {
          debugPrint('⚠️ Lỗi tự tạo tài liệu profile mặc định: $e');
        }
      } else {
        try {
          if (doc.data() != null) {
            userProfile.value = UserProfileModel.fromMap(doc.data() as Map<String, dynamic>);
          }
        } catch (e) {
          debugPrint('⚠️ Lỗi phân tích dữ liệu profile từ Firestore: $e');
        }
      }
    }, onError: (error) {
      debugPrint('⚠️ Lỗi kết nối luồng dữ liệu profile: $error');
    });
  }

  // Cập nhật thông tin profile lên Firestore
  Future<bool> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String dob,
    required String gender,
    String? skinType,
    bool? isSensitive,
  }) async {
    final String uid = _authController.currentUserId.value;
    if (uid.isEmpty || _authController.isGuest) {
      Get.snackbar(
        'Lỗi phân quyền',
        'Vui lòng đăng ký/đăng nhập tài khoản Email để sử dụng chức năng cập nhật thông tin cá nhân!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withValues(alpha: 0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    }

    // Validation cơ bản đầu vào
    if (fullName.trim().isEmpty) {
      Get.snackbar(
        'Lỗi nhập liệu',
        'Họ và tên không được để trống!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withValues(alpha: 0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    }

    if (phoneNumber.trim().isNotEmpty && !GetUtils.isPhoneNumber(phoneNumber.trim())) {
      Get.snackbar(
        'Lỗi nhập liệu',
        'Số điện thoại không đúng định dạng!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withValues(alpha: 0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    }

    try {
      isLoading.value = true;
      
      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'dob': dob.trim(),
        'gender': gender,
        if (skinType != null) 'skinType': skinType,
        if (isSensitive != null) 'isSensitive': isSensitive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi cập nhật',
        'Không thể cập nhật hồ sơ: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withValues(alpha: 0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cập nhật loại da và độ nhạy cảm lên Firestore (gọi từ RoutineController một cách độc lập)
  Future<bool> updateSkinTypeAndSensitivity(String skinType, bool isSensitive) async {
    final String uid = _authController.currentUserId.value;
    if (uid.isEmpty || _authController.isGuest) {
      return false;
    }
    try {
      await _firestore.collection('users').doc(uid).update({
        'skinType': skinType,
        'isSensitive': isSensitive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('⚠️ [ProfileController] Lỗi cập nhật skin type/sensitivity lên Firestore: $e');
      return false;
    }
  }
}
