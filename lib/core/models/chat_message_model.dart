class ChatMessageModel {
  final String text;
  final bool isUser; // true: Người dùng, false: AI
  final DateTime timestamp;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Dịch từ JSON (GetStorage) sang Dart Object
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? true, // Mặc định là user nếu thiếu data
      // Chuyển từ chuỗi chuẩn ISO 8601 về lại kiểu DateTime
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  // Dịch từ Dart Object sang JSON để lưu vào GetStorage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      // Ép kiểu thời gian ra chuỗi văn bản chuẩn quốc tế (VD: "2026-03-27T10:30:00.000")
      'timestamp': timestamp.toIso8601String(),
    };
  }
}