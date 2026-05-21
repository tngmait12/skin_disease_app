import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/local_storage_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Biến quan sát trạng thái người dùng Firebase
  final Rxn<User> firebaseUser = Rxn<User>();
  
  // ID người dùng hiện tại (cho Firestore và Local DB)
  final RxString currentUserId = ''.obs;
  
  // Trạng thái đang tải dữ liệu
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi trạng thái xác thực từ Firebase
    firebaseUser.bindStream(_auth.authStateChanges());
    
    // Tự động đồng bộ hóa currentUserId khi người dùng thay đổi
    ever(firebaseUser, _handleUserChange);
  }

  void _handleUserChange(User? user) {
    if (user != null) {
      currentUserId.value = user.uid;
      print('👤 Đã xác thực người dùng: ${user.isAnonymous ? "Khách ẩn danh" : user.email} (UID: ${user.uid})');
    } else {
      currentUserId.value = '';
      print('👤 Người dùng đã đăng xuất hoặc chưa xác thực');
    }
  }

  // 1. Đăng ký bằng Email & Mật khẩu
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      // Tự động khởi tạo tài liệu profile mặc định trên Firestore cho người dùng mới
      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'fullName': 'Thành viên SkinShield',
          'phoneNumber': '',
          'dob': '',
          'gender': 'Chưa xác định',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      Get.snackbar(
        'Thành công',
        'Đăng ký tài khoản mới thành công!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2A9D8F).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại!';
      if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn!';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email này đã được đăng ký cho tài khoản khác!';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email không đúng định dạng!';
      }
      Get.snackbar(
        'Lỗi đăng ký',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Lỗi hệ thống',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Đăng nhập bằng Email & Mật khẩu
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar(
        'Thành công',
        'Chào mừng bạn quay lại!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2A9D8F).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Tài khoản hoặc mật khẩu không chính xác!';
      if (e.code == 'user-not-found') {
        errorMessage = 'Tài khoản email này không tồn tại!';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mật khẩu không chính xác!';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Địa chỉ email không hợp lệ!';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Tài khoản này đã bị vô hiệu hóa!';
      }
      Get.snackbar(
        'Lỗi đăng nhập',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Lỗi hệ thống',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 3. Trải nghiệm làm khách (Đăng nhập ẩn danh - Anonymous)
  Future<bool> signInAnonymously() async {
    try {
      isLoading.value = true;
      await _auth.signInAnonymously();
      Get.snackbar(
        'Chế độ khách',
        'Bắt đầu phiên làm việc ẩn danh.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF457B9D).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi chế độ khách',
        'Không thể bắt đầu phiên ẩn danh: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 5. Liên kết tài khoản khách với Email & Mật khẩu (Nâng cấp tài khoản khách)
  Future<bool> linkGuestWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null && currentUser.isAnonymous) {
        // Tạo thông tin xác thực từ email và mật khẩu mới
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        
        // Liên kết tài khoản ẩn danh hiện tại với thông tin xác thực này
        await currentUser.linkWithCredential(credential);
        
        // Khởi tạo hoặc hợp nhất tài liệu profile trong Firestore để đồng bộ hóa Email mới
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'uid': currentUser.uid,
          'email': email,
          'fullName': 'Thành viên SkinShield',
          'phoneNumber': '',
          'dob': '',
          'gender': 'Chưa xác định',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Tải lại thông tin người dùng từ Firebase để cập nhật trạng thái mới nhất
        await currentUser.reload();
        // Cập nhật thủ công biến quan sát để đồng bộ GetX ngay lập tức
        firebaseUser.value = _auth.currentUser;
        
        Get.snackbar(
          'Thành công',
          'Tài khoản khách đã nâng cấp lên tài khoản Email thành công! Toàn bộ lịch sử chẩn đoán của bạn đã được giữ lại.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF2A9D8F).withOpacity(0.8),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 5),
        );
        return true;
      } else {
        Get.snackbar(
          'Lỗi liên kết',
          'Không tìm thấy phiên làm việc ẩn danh hợp lệ để nâng cấp.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Có lỗi xảy ra khi liên kết tài khoản.';
      if (e.code == 'provider-already-linked') {
        errorMessage = 'Tài khoản này đã được liên kết với một nhà cung cấp khác!';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Thông tin xác thực không hợp lệ!';
      } else if (e.code == 'credential-already-in-use') {
        errorMessage = 'Địa chỉ email này đã được sử dụng bởi một tài khoản khác. Vui lòng sử dụng email khác!';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu mới quá yếu!';
      }
      Get.snackbar(
        'Lỗi nâng cấp',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE63946).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Lỗi hệ thống',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 4. Đăng xuất
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      
      // Nếu là tài khoản Khách ẩn danh, dọn dẹp sạch dữ liệu cục bộ của UID này trước khi đăng xuất
      if (isGuest && currentUserId.value.isNotEmpty) {
        try {
          final LocalStorageService storage = Get.find<LocalStorageService>();
          await storage.clearUserData(currentUserId.value);
          print('🗑️ Đã xóa sạch dữ liệu cục bộ của Khách ẩn danh: ${currentUserId.value}');
        } catch (e) {
          print('⚠️ Không thể dọn dẹp dữ liệu khách trước khi đăng xuất: $e');
        }
      }
      
      await _auth.signOut();
      Get.snackbar(
        'Đã đăng xuất',
        'Hẹn gặp lại bạn lần sau!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF457B9D).withOpacity(0.8),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi đăng xuất',
        'Có lỗi khi đăng xuất: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Kiểm tra xem người dùng hiện tại có phải là ẩn danh không
  bool get isGuest => firebaseUser.value?.isAnonymous ?? true;

  // Lấy email người dùng (hoặc 'Khách ẩn danh' nếu là ẩn danh)
  String get userEmail => isGuest ? 'Khách ẩn danh' : (firebaseUser.value?.email ?? 'Không xác định');
}