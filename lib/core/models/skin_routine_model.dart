import 'routine_step_model.dart';

/// Định nghĩa cấu trúc phác đồ hoàn chỉnh được sinh động.
class SkinRoutine {
  final String conditionName;
  final String medicalAlert;
  final List<RoutineStep> morningRoutine;
  final List<RoutineStep> eveningRoutine;
  final List<String> recommendIngredients;
  final List<String> avoidIngredients;
  final List<ProductRecommendation> recommendedProducts;

  SkinRoutine({
    required this.conditionName,
    this.medicalAlert = '',
    required this.morningRoutine,
    required this.eveningRoutine,
    required this.recommendIngredients,
    required this.avoidIngredients,
    required this.recommendedProducts,
  });

  factory SkinRoutine.fromJson(Map<String, dynamic> json) {
    return SkinRoutine(
      conditionName: json['conditionName'] ?? '',
      medicalAlert: json['medicalAlert'] ?? '',
      recommendIngredients: List<String>.from(json['recommendIngredients'] ?? []),
      avoidIngredients: List<String>.from(json['avoidIngredients'] ?? []),
      morningRoutine: (json['morningRoutine'] as List?)?.map((e) => RoutineStep.fromJson(e)).toList() ?? [],
      eveningRoutine: (json['eveningRoutine'] as List?)?.map((e) => RoutineStep.fromJson(e)).toList() ?? [],
      recommendedProducts: (json['recommendedProducts'] as List?)?.map((e) => ProductRecommendation.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conditionName': conditionName,
      'medicalAlert': medicalAlert,
      'recommendIngredients': recommendIngredients,
      'avoidIngredients': avoidIngredients,
      'morningRoutine': morningRoutine.map((e) => e.toJson()).toList(),
      'eveningRoutine': eveningRoutine.map((e) => e.toJson()).toList(),
      'recommendedProducts': recommendedProducts.map((e) => e.toJson()).toList(),
    };
  }
}

/// Hồ sơ da người dùng cơ bản phục vụ Routine.
class UserSkinProfile {
  final String skinType; // 'Oily' (Da Dầu), 'Dry' (Da Khô)
  final bool isSensitive;

  UserSkinProfile({
    required this.skinType,
    required this.isSensitive,
  });

  factory UserSkinProfile.fromJson(Map<String, dynamic> json) => UserSkinProfile(
    skinType: json['skinType'] ?? 'Oily',
    isSensitive: json['isSensitive'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'skinType': skinType,
    'isSensitive': isSensitive,
  };
}
