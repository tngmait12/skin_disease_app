import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String dob; // Định dạng yyyy-MM-dd
  final String gender; // Nam, Nữ, Khác, Chưa xác định
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.dob,
    required this.gender,
    this.createdAt,
    this.updatedAt,
  });

  // Sao chép đối tượng với một số thuộc tính mới thay đổi
  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? dob,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Chuyển đổi dữ liệu sang dạng Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dob': dob,
      'gender': gender,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(), // Tự động cập nhật thời gian sửa trên Firestore
    };
  }

  // Khởi tạo đối tượng từ Map nhận được từ Firestore
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? 'Thành viên SkinShield',
      phoneNumber: map['phoneNumber'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? 'Chưa xác định',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // Hàm hỗ trợ phân tích an toàn kiểu DateTime từ Firestore Timestamp hoặc String
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
