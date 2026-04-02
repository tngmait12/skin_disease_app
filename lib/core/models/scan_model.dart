import 'package:cloud_firestore/cloud_firestore.dart';

class ScanModel {
  String id; // Bắt buộc phải có để Local DB và Cloud nhận diện nhau
  final String userId;
  final String localImagePath; // Đường dẫn ảnh trên máy (dùng khi offline)
  final String firebaseImageUrl; // Link Cloudinary/Firebase (dùng khi online)
  final String diseaseName;
  final double confidence;
  final DateTime date;

  // Biến đánh dấu: true = Đã lên Cloud, false = Đang nằm ở Local chờ mạng
  bool isSynced;

  ScanModel({
    required this.id,
    required this.userId,
    required this.localImagePath,
    this.firebaseImageUrl = '',
    required this.diseaseName,
    required this.confidence,
    required this.date,
    this.isSynced = false,
  });

  // ==========================================
  // 1. GIAO TIẾP VỚI LOCAL DB (GET STORAGE / JSON)
  // ==========================================

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      localImagePath: json['localImagePath'] ?? '',
      firebaseImageUrl: json['firebaseImageUrl'] ?? '',
      diseaseName: json['diseaseName'] ?? 'Không xác định',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      // Đọc từ chuỗi String ISO-8601 về DateTime
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      isSynced: json['isSynced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'localImagePath': localImagePath,
      'firebaseImageUrl': firebaseImageUrl,
      'diseaseName': diseaseName,
      'confidence': confidence,
      // Ép ra chuỗi String chuẩn quốc tế để GetStorage không bị lỗi
      'date': date.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // ==========================================
  // 2. GIAO TIẾP VỚI CLOUD DB (FIRESTORE)
  // ==========================================

  factory ScanModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      localImagePath: data['localImagePath'] ?? '',
      // Map thuộc tính imagePath cũ của bạn thành firebaseImageUrl để không mất data cũ
      firebaseImageUrl: data['firebaseImageUrl'] ?? data['imagePath'] ?? '',
      diseaseName: data['diseaseName'] ?? 'Không xác định',
      confidence: (data['confidence'] ?? 0.0).toDouble(),

      // 💡 BẢO VỆ KÉP: Tránh lỗi Crash do lúc thì Timestamp lúc thì String
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.parse(data['date'].toString()),

      isSynced: data['isSynced'] ?? true, // Kéo từ Firebase về thì chắc chắn đã sync
    );
  }

  // Mình giữ lại tên toMap() giống code cũ của bạn để file HistoryController không bị báo lỗi đỏ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'localImagePath': localImagePath,
      'firebaseImageUrl': firebaseImageUrl, // Link Cloudinary
      'diseaseName': diseaseName,
      'confidence': confidence,
      // Firebase bắt buộc phải dùng Timestamp
      'date': Timestamp.fromDate(date),
      'isSynced': isSynced,
    };
  }
}