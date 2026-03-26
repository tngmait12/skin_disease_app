import 'package:flutter/material.dart';

// 1. MODEL: Định nghĩa cấu trúc của 1 bước chăm sóc (Ví dụ: Rửa mặt)
class RoutineStep {
  final String title;
  final String description;
  final IconData icon;
  final bool isWarning; // Để đánh dấu màu đỏ cho những bước CẤM làm (ví dụ: Không nặn mụn)

  RoutineStep({
    required this.title,
    required this.description,
    required this.icon,
    this.isWarning = false,
  });
}

class ProductRecommendation {
  final String category;     // Loại (VD: Sữa rửa mặt, Serum)
  final String brandAndName; // Tên SP (VD: CeraVe Hydrating Cleanser)
  final String reason;       // Lý do khuyên dùng (VD: Có Ceramides phục hồi rào bảo vệ)
  final String? imageUrl;    // (Tùy chọn) Link ảnh sản phẩm

  ProductRecommendation({required this.category, required this.brandAndName, required this.reason, this.imageUrl});
}

// 2. MODEL: Định nghĩa toàn bộ quy trình cho 1 loại bệnh
class SkinRoutine {
  final String conditionName;
  final String medicalAlert; // Cảnh báo đỏ (Dành cho ung thư/bệnh nặng)
  final List<RoutineStep> morningRoutine;
  final List<RoutineStep> eveningRoutine;
  final List<String> recommendIngredients; // Hoạt chất khuyên dùng
  final List<String> avoidIngredients; // Hoạt chất nên tránh

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
}

// 3. DATABASE: Từ điển ánh xạ
final Map<String, SkinRoutine> routineDatabase = {

  // ==========================================
  // NHÓM 1: KHỎE MẠNH (Basic Skincare)
  // ==========================================
  'Healthy': SkinRoutine(
    conditionName: 'Da Khỏe Mạnh',
    recommendIngredients: ['Hyaluronic Acid', 'Vitamin C', 'Ceramides'],
    avoidIngredients: ['Sản phẩm tẩy rửa quá mạnh (pH cao)'],
    morningRoutine: [
      RoutineStep(title: 'Rửa mặt', description: 'Dùng sữa rửa mặt dịu nhẹ hoặc chỉ rửa bằng nước ấm.', icon: Icons.water_drop_outlined),
      RoutineStep(title: 'Dưỡng ẩm', description: 'Thoa kem dưỡng mỏng nhẹ để khóa ẩm.', icon: Icons.spa_outlined),
      RoutineStep(title: 'Chống nắng', description: 'Bôi kem chống nắng SPF 30+ trước khi ra ngoài 20 phút.', icon: Icons.wb_sunny_outlined),
    ],
    eveningRoutine: [
      RoutineStep(title: 'Tẩy trang', description: 'Loại bỏ bụi bẩn và kem chống nắng.', icon: Icons.cleaning_services_outlined),
      RoutineStep(title: 'Rửa mặt', description: 'Làm sạch sâu bằng sữa rửa mặt tạo bọt.', icon: Icons.water_drop),
      RoutineStep(title: 'Dưỡng ẩm', description: 'Dùng kem dưỡng ẩm ban đêm phục hồi da.', icon: Icons.nightlight_round),
    ],
    recommendedProducts: [
      ProductRecommendation(
        category: 'Sữa rửa mặt',
        brandAndName: 'La Roche-Posay Effaclar Purifying Foaming Gel',
        reason: 'Độ pH 5.5 chuẩn xác, chứa Zinc PCA giúp kiểm soát bã nhờn mà không làm khô da.',
      ),
      ProductRecommendation(
        category: 'Đặc trị',
        brandAndName: 'Paula\'s Choice Skin Perfecting 2% BHA Liquid',
        reason: 'Chứa 2% Salicylic Acid tẩy da chết sâu trong lỗ chân lông, đẩy lùi mụn ẩn.',
      ),
      ProductRecommendation(
        category: 'Dưỡng ẩm',
        brandAndName: 'Neutrogena Hydro Boost Water Gel',
        reason: 'Kết cấu dạng gel nước (Oil-free) mỏng nhẹ, không gây bít tắc lỗ chân lông (Non-comedogenic).',
      ),
    ],
  ),

  // ==========================================
  // NHÓM 2: MỤN TRỨNG CÁ (Acne & Rosacea)
  // ==========================================
  'Acne': SkinRoutine(
    conditionName: 'Mụn Trứng Cá',
    recommendIngredients: ['Salicylic Acid (BHA)', 'Niacinamide', 'Benzoyl Peroxide'],
    avoidIngredients: ['Dầu dừa', 'Hương liệu (Fragrance)', 'Cồn khô (Alcohol Denat)'],
    morningRoutine: [
      RoutineStep(title: 'Làm sạch', description: 'Sữa rửa mặt có chứa BHA 1-2% giúp làm sạch lỗ chân lông.', icon: Icons.water_drop_outlined),
      RoutineStep(title: 'Chấm mụn (Tùy chọn)', description: 'Chấm Gel giảm mụn lên các nốt mụn viêm.', icon: Icons.healing_outlined),
      RoutineStep(title: 'Dưỡng ẩm', description: 'Bắt buộc dùng dạng Gel/Lotion không chứa dầu (Oil-free).', icon: Icons.spa_outlined),
      RoutineStep(title: 'Bảo vệ', description: 'Kem chống nắng dành riêng cho da mụn.', icon: Icons.wb_sunny_outlined),
    ],
    eveningRoutine: [
      RoutineStep(title: 'Làm sạch kép (Double Cleansing)', description: 'Tẩy trang kỹ + Sữa rửa mặt.', icon: Icons.cleaning_services),
      RoutineStep(title: 'Đặc trị', description: 'Thoa mỏng serum Niacinamide hoặc BHA (2-3 lần/tuần).', icon: Icons.science_outlined),
      RoutineStep(title: 'Dưỡng ẩm', description: 'Khóa ẩm bằng gel dưỡng phục hồi.', icon: Icons.nightlight_round),
      RoutineStep(title: 'CẢNH BÁO', description: 'Tuyệt đối không dùng tay tự nặn mụn viêm để tránh sẹo rỗ và nhiễm trùng.', icon: Icons.warning_amber_rounded, isWarning: true),
    ],
    recommendedProducts: [
      ProductRecommendation(
        category: 'Sữa rửa mặt',
        brandAndName: 'La Roche-Posay Effaclar Purifying Foaming Gel',
        reason: 'Độ pH 5.5 chuẩn xác, chứa Zinc PCA giúp kiểm soát bã nhờn mà không làm khô da.',
      ),
      ProductRecommendation(
        category: 'Đặc trị',
        brandAndName: 'Paula\'s Choice Skin Perfecting 2% BHA Liquid',
        reason: 'Chứa 2% Salicylic Acid tẩy da chết sâu trong lỗ chân lông, đẩy lùi mụn ẩn.',
      ),
      ProductRecommendation(
        category: 'Dưỡng ẩm',
        brandAndName: 'Neutrogena Hydro Boost Water Gel',
        reason: 'Kết cấu dạng gel nước (Oil-free) mỏng nhẹ, không gây bít tắc lỗ chân lông (Non-comedogenic).',
      ),
    ],
  ),

  // ==========================================
  // NHÓM 3: CHÀM / VIÊM DA CƠ ĐỊA (Eczema)
  // ==========================================
  'Eczema': SkinRoutine(
    conditionName: 'Chàm / Viêm da cơ địa',
    recommendIngredients: ['Ceramides', 'Panthenol (B5)', 'Glycerin'],
    avoidIngredients: ['Hương liệu', 'Chất tạo bọt SLS/SLES', 'Nước quá nóng'],
    morningRoutine: [
      RoutineStep(title: 'Làm sạch dịu nhẹ', description: 'Rửa mặt/Tắm bằng nước mát, dùng sữa rửa mặt không tạo bọt.', icon: Icons.water_drop_outlined),
      RoutineStep(title: 'Bôi kem lập tức', description: 'Thoa kem dưỡng ẩm dày (Cream/Ointment) ngay khi da còn hơi ẩm (Quy tắc 3 phút).', icon: Icons.spa),
    ],
    eveningRoutine: [
      RoutineStep(title: 'Làm sạch', description: 'Tắm/Rửa mặt nhanh, không chà xát mạnh.', icon: Icons.clean_hands_outlined),
      RoutineStep(title: 'Dưỡng phục hồi', description: 'Bôi lớp kem dưỡng phục hồi hàng rào bảo vệ da dày hơn ban ngày.', icon: Icons.nightlight),
      RoutineStep(title: 'Tránh gãi', description: 'Nếu quá ngứa, hãy chườm mát thay vì gãi để tránh xước da bội nhiễm.', icon: Icons.do_not_touch, isWarning: true),
    ],
    recommendedProducts: [
      ProductRecommendation(
        category: 'Sữa rửa mặt',
        brandAndName: 'La Roche-Posay Effaclar Purifying Foaming Gel',
        reason: 'Độ pH 5.5 chuẩn xác, chứa Zinc PCA giúp kiểm soát bã nhờn mà không làm khô da.',
      ),
      ProductRecommendation(
        category: 'Đặc trị',
        brandAndName: 'Paula\'s Choice Skin Perfecting 2% BHA Liquid',
        reason: 'Chứa 2% Salicylic Acid tẩy da chết sâu trong lỗ chân lông, đẩy lùi mụn ẩn.',
      ),
      ProductRecommendation(
        category: 'Dưỡng ẩm',
        brandAndName: 'Neutrogena Hydro Boost Water Gel',
        reason: 'Kết cấu dạng gel nước (Oil-free) mỏng nhẹ, không gây bít tắc lỗ chân lông (Non-comedogenic).',
      ),
    ],
  ),

  // ==========================================
  // NHÓM 4: UNG THƯ / ÁC TÍNH (Báo động đỏ)
  // ==========================================
  'Melanoma': SkinRoutine(
    conditionName: 'Ung thư hắc tố / Ác tính',
    medicalAlert: 'CẢNH BÁO Y TẾ KHẨN CẤP: Đây là tình trạng nguy hiểm. KHÔNG có quy trình mỹ phẩm nào có thể chữa trị. Hãy đến bệnh viện Da liễu ngay lập tức để sinh thiết!',
    recommendIngredients: ['KHÔNG TỰ Ý BÔI THUỐC'],
    avoidIngredients: ['TẤT CẢ CÁC LOẠI MỸ PHẨM/THUỐC BÔI TỰ KÊ'],
    morningRoutine: [
      RoutineStep(title: 'Bảo vệ tuyệt đối', description: 'Che chắn kín vùng da bệnh, tuyệt đối không để tiếp xúc với ánh nắng mặt trời.', icon: Icons.shield_outlined),
      RoutineStep(title: 'Đi khám ngay', description: 'Đặt lịch hẹn với Bác sĩ chuyên khoa Ung bướu / Da liễu.', icon: Icons.local_hospital, isWarning: true),
    ],
    eveningRoutine: [
      RoutineStep(title: 'Giữ vệ sinh', description: 'Chỉ rửa nhẹ nhàng bằng nước muối sinh lý hoặc nước sạch.', icon: Icons.water_drop),
      RoutineStep(title: 'Theo dõi', description: 'Không gãi, không bóc vảy, không tác động vật lý lên khối u/nốt ruồi bất thường.', icon: Icons.do_not_touch, isWarning: true),
    ],
    recommendedProducts: [
      ProductRecommendation(
        category: 'Sữa rửa mặt',
        brandAndName: 'La Roche-Posay Effaclar Purifying Foaming Gel',
        reason: 'Độ pH 5.5 chuẩn xác, chứa Zinc PCA giúp kiểm soát bã nhờn mà không làm khô da.',
      ),
      ProductRecommendation(
        category: 'Đặc trị',
        brandAndName: 'Paula\'s Choice Skin Perfecting 2% BHA Liquid',
        reason: 'Chứa 2% Salicylic Acid tẩy da chết sâu trong lỗ chân lông, đẩy lùi mụn ẩn.',
      ),
      ProductRecommendation(
        category: 'Dưỡng ẩm',
        brandAndName: 'Neutrogena Hydro Boost Water Gel',
        reason: 'Kết cấu dạng gel nước (Oil-free) mỏng nhẹ, không gây bít tắc lỗ chân lông (Non-comedogenic).',
      ),
    ],
  ),

};

// 4. HÀM HỖ TRỢ: Lấy Routine chuẩn dựa vào Tên bệnh do AI trả về
SkinRoutine getRoutineForDisease(String aiDiseaseName) {
  for (var key in routineDatabase.keys) {
    if (aiDiseaseName.toLowerCase().contains(key.toLowerCase())) {
      return routineDatabase[key]!;
    }
  }
  return routineDatabase['Healthy']!;
}