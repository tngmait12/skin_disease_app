/// Định nghĩa cấu trúc của một bước chăm sóc da cụ thể.
class RoutineStep {
  final String title;
  final String description;
  final String iconName;
  final bool isWarning; // Đánh dấu màu đỏ cho cảnh báo khẩn cấp/chống chỉ định
  final bool isCustom;  // Nhận diện bước do người dùng tự thêm

  RoutineStep({
    required this.title,
    required this.description,
    required this.iconName,
    this.isWarning = false,
    this.isCustom = false,
  });

  factory RoutineStep.fromJson(Map<String, dynamic> json) => RoutineStep(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    iconName: json['iconName'] ?? 'circle',
    isWarning: json['isWarning'] ?? false,
    isCustom: json['isCustom'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'iconName': iconName,
    'isWarning': isWarning,
    'isCustom': isCustom,
  };
}

/// Đề xuất sản phẩm cụ thể.
class ProductRecommendation {
  final String category;     // Phân loại (Sữa rửa mặt, Đặc trị, Dưỡng ẩm)
  final String brandAndName; // Thương hiệu và tên sản phẩm
  final String reason;       // Lý do bác sĩ da liễu khuyên dùng
  final String? imageUrl;    // Link ảnh sản phẩm

  ProductRecommendation({
    required this.category,
    required this.brandAndName,
    required this.reason,
    this.imageUrl,
  });

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) => ProductRecommendation(
    category: json['category'] ?? '',
    brandAndName: json['brandAndName'] ?? '',
    reason: json['reason'] ?? '',
    imageUrl: json['imageUrl'],
  );

  Map<String, dynamic> toJson() => {
    'category': category,
    'brandAndName': brandAndName,
    'reason': reason,
    'imageUrl': imageUrl,
  };
}
