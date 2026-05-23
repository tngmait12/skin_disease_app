import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/routine_step_model.dart';
import '../models/skin_routine_model.dart';
import '../models/pathological_family.dart';

/// Lớp tĩnh quản lý bộ dữ liệu phác đồ y khoa y khoa song ngữ tải động từ JSON.
class RoutineGenerator {
  static Map<String, dynamic>? _data;

  /// Nạp tệp JSON phác đồ chăm sóc da bất đồng bộ lúc khởi chạy ứng dụng (Splash Screen).
  static Future<void> initialize() async {
    try {
      final String jsonStr = await rootBundle.loadString('assets/data/routines.json');
      _data = json.decode(jsonStr);
      debugPrint('✅ [RoutineGenerator] Đã nạp thành công bộ dữ liệu phác đồ y khoa song ngữ.');
    } catch (e) {
      debugPrint('❌ [RoutineGenerator] Lỗi khi nạp dữ liệu routines.json: $e');
    }
  }

  /// Sinh phác đồ y khoa động từ dữ liệu JSON đã tải sẵn, dựa theo ngôn ngữ hiện tại của GetX.
  static SkinRoutine generateDynamicRoutine(String? rawDiseaseLabel, UserSkinProfile? profile) {
    final String safeLabel = rawDiseaseLabel ?? 'Da khỏe mạnh (Heathy)';
    final UserSkinProfile safeProfile = profile ?? UserSkinProfile(skinType: 'Oily', isSensitive: false);

    final PathologicalFamily family = diseaseFamilyMap[safeLabel] ?? PathologicalFamily.inflammatory;
    final String familyKey = family.name; // VD: 'critical', 'inflammatory', 'eczematous'
    
    // Phát hiện ngôn ngữ hiện tại ('vi' hoặc 'en')
    final String lang = Get.locale?.languageCode == 'en' ? 'en' : 'vi';

    // Dịch tên bệnh thân thiện
    String friendlyName = safeLabel;
    if (_data != null && _data!['disease_names'] != null && _data!['disease_names'][safeLabel] != null) {
      friendlyName = _data!['disease_names'][safeLabel][lang] ?? safeLabel;
    } else {
      // Fallback khi chưa nạp JSON hoặc thiếu nhãn
      friendlyName = lang == 'vi' ? (diseaseVietnameseNames[safeLabel] ?? safeLabel) : safeLabel;
    }

    List<RoutineStep> morning = [];
    List<RoutineStep> evening = [];
    List<String> recommends = [];
    List<String> avoids = [];
    List<ProductRecommendation> products = [];
    String medicalAlert = '';

    // Lấy dữ liệu cụm bệnh lý từ JSON
    final Map<String, dynamic>? familyData = _data != null && _data!['pathological_families'] != null
        ? _data!['pathological_families'][familyKey]
        : null;

    if (familyData != null) {
      // 1. Cảnh báo y tế
      final alertData = familyData['medicalAlert'];
      if (alertData != null) {
        medicalAlert = alertData[lang] ?? '';
      }

      // 2. Thành phần khuyên dùng và khuyên tránh
      final recommendData = familyData['recommendIngredients'];
      if (recommendData != null) {
        recommends = List<String>.from(recommendData[lang] ?? []);
      }

      final avoidData = familyData['avoidIngredients'];
      if (avoidData != null) {
        avoids = List<String>.from(avoidData[lang] ?? []);
      }

      // 3. Buổi sáng cơ sở (Morning Routine)
      final morningData = familyData['morningRoutine'] as List?;
      if (morningData != null) {
        for (var stepMap in morningData) {
          morning.add(RoutineStep(
            title: stepMap['title'][lang] ?? '',
            description: stepMap['description'][lang] ?? '',
            iconName: stepMap['iconName'] ?? '',
            isWarning: stepMap['isWarning'] ?? false,
          ));
        }
      }

      // 4. Buổi tối cơ sở (Evening Routine)
      final eveningData = familyData['eveningRoutine'] as List?;
      if (eveningData != null) {
        for (var stepMap in eveningData) {
          // Xử lý bước chấm mụn có điều kiện cho da nhạy cảm (inflammatory)
          if (stepMap['isConditionalSensitive'] == true) {
            final Map<String, dynamic> selectedStep = safeProfile.isSensitive
                ? stepMap['sensitive']
                : stepMap['normal'];
            
            evening.add(RoutineStep(
              title: selectedStep['title'][lang] ?? '',
              description: selectedStep['description'][lang] ?? '',
              iconName: selectedStep['iconName'] ?? '',
              isWarning: selectedStep['isWarning'] ?? false,
            ));
          } else {
            evening.add(RoutineStep(
              title: stepMap['title'][lang] ?? '',
              description: stepMap['description'][lang] ?? '',
              iconName: stepMap['iconName'] ?? '',
              isWarning: stepMap['isWarning'] ?? false,
            ));
          }
        }
      }

      // 5. Sản phẩm khuyên dùng (Recommended Products)
      final productsData = familyData['recommendedProducts'] as List?;
      if (productsData != null) {
        for (var prodMap in productsData) {
          products.add(ProductRecommendation(
            category: prodMap['category'][lang] ?? '',
            brandAndName: prodMap['brandAndName'][lang] ?? '',
            reason: prodMap['reason'][lang] ?? '',
          ));
        }
      }
    }

    // ==========================================================
    // LẮP GHÉP BƯỚC ĐỘNG TÙY BIẾN THEO LOẠI DA (DA DẦU / KHÁC)
    // ==========================================================
    if (family != PathologicalFamily.critical && _data != null && _data!['skin_type_rules'] != null) {
      final rules = _data!['skin_type_rules'];
      final String skinKey = safeProfile.skinType == 'Oily' ? 'Oily' : 'default';

      // A. Bước rửa mặt ban sáng (đầu danh sách sáng)
      final washRule = rules['cleansing']?[skinKey];
      if (washRule != null) {
        morning.insert(0, RoutineStep(
          title: washRule['title'][lang] ?? '',
          description: washRule['description'][lang] ?? '',
          iconName: washRule['iconName'] ?? 'water_drop',
        ));
      }

      // B. Bước chống nắng ban sáng (cuối danh sách sáng)
      final sunRule = rules['sunscreen']?[skinKey];
      if (sunRule != null) {
        morning.add(RoutineStep(
          title: sunRule['title'][lang] ?? '',
          description: sunRule['description'][lang] ?? '',
          iconName: sunRule['iconName'] ?? 'wb_sunny',
        ));
      }
    }

    return SkinRoutine(
      conditionName: friendlyName,
      medicalAlert: medicalAlert,
      morningRoutine: morning,
      eveningRoutine: evening,
      recommendIngredients: recommends,
      avoidIngredients: avoids,
      recommendedProducts: products,
    );
  }

  /// Khử khớp nối tương thích ngược
  static SkinRoutine getRoutineForDisease(String? aiDiseaseName) {
    final String safeName = aiDiseaseName ?? 'Da khỏe mạnh (Heathy)';
    String matchedLabel = 'Da khỏe mạnh (Heathy)';
    for (var key in diseaseFamilyMap.keys) {
      if (safeName.toLowerCase().contains(key.toLowerCase()) || 
          key.toLowerCase().contains(safeName.toLowerCase())) {
        matchedLabel = key;
        break;
      }
    }

    return generateDynamicRoutine(
      matchedLabel, 
      UserSkinProfile(skinType: 'Oily', isSensitive: false)
    );
  }
}

// ==========================================================
// CÁC HÀM TOÀN CỤC WRAPPER ĐỂ ĐẢM BẢO TƯƠNG THÍCH NGƯỢC 100%
// ==========================================================

SkinRoutine generateDynamicRoutine(String? rawDiseaseLabel, UserSkinProfile? profile) {
  return RoutineGenerator.generateDynamicRoutine(rawDiseaseLabel, profile);
}

SkinRoutine getRoutineForDisease(String? aiDiseaseName) {
  return RoutineGenerator.getRoutineForDisease(aiDiseaseName);
}
