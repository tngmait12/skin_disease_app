import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  String? id;
  final String imagePath; // Đường dẫn ảnh trên máy
  final String diseaseName; // Tên bệnh
  final double confidence;  // Độ tin cậy (ví dụ: 0.95 tương đương 95%)
  final DateTime date;      // Ngày khám

  HistoryModel({
    this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'date': Timestamp.fromDate(date), // Firestore dùng kiểu Timestamp
    };
  }

  factory HistoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HistoryModel(
      id: doc.id,
      imagePath: data['imagePath'] ?? '',
      diseaseName: data['diseaseName'] ?? 'Không xác định',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}