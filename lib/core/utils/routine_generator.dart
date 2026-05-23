import '../models/routine_step_model.dart';
import '../models/skin_routine_model.dart';
import '../models/pathological_family.dart';

/// Hàm sinh phác đồ cá nhân hóa dựa trên Cụm bệnh lý của 35 bệnh lý và Hồ sơ da của người dùng.
SkinRoutine generateDynamicRoutine(String? rawDiseaseLabel, UserSkinProfile? profile) {
  final String safeLabel = rawDiseaseLabel ?? 'Da khỏe mạnh (Heathy)';
  final UserSkinProfile safeProfile = profile ?? UserSkinProfile(skinType: 'Oily', isSensitive: false);

  final PathologicalFamily family = diseaseFamilyMap[safeLabel] ?? PathologicalFamily.inflammatory;
  final String friendlyName = diseaseVietnameseNames[safeLabel] ?? safeLabel;

  List<RoutineStep> morning = [];
  List<RoutineStep> evening = [];
  List<String> recommends = [];
  List<String> avoids = [];
  List<ProductRecommendation> products = [];
  String medicalAlert = '';

  // ==========================================================
  // LỚP CHẶN AN TOÀN Y TẾ: PHÂN KHÚC NGUY CẤP (UNG THƯ / BÁO ĐỘNG ĐỎ)
  // ==========================================================
  if (family == PathologicalFamily.critical) {
    return SkinRoutine(
      conditionName: friendlyName,
      medicalAlert: 'CẢNH BÁO NGUY CẤP: Dấu hiệu tổn thương nghi ngờ ác tính (Ung thư da). TUYỆT ĐỐI KHÔNG sử dụng mỹ phẩm dưỡng da thông thường lên khu vực này. Bạn cần đặt lịch khám sinh thiết với Bác sĩ Da liễu / Ung bướu lập tức.',
      recommendIngredients: [],
      avoidIngredients: ['Mỹ phẩm dưỡng da', 'Sữa rửa mặt có hạt tẩy da chết', 'Các loại thuốc nam/lá đắp tự chế'],
      morningRoutine: [
        RoutineStep(
          title: 'Che chắn tuyệt đối',
          description: 'Sử dụng khẩu trang y tế dày, mũ rộng vành, che kín vùng da bệnh khỏi nắng mặt trời.',
          iconName: 'shield',
        ),
        RoutineStep(
          title: 'Đi khám ngay',
          description: 'Đến trực tiếp bệnh viện chuyên khoa Da liễu để được khám chuyên sâu.',
          iconName: 'local_hospital',
          isWarning: true,
        ),
      ],
      eveningRoutine: [
        RoutineStep(
          title: 'Vệ sinh nhẹ nhàng',
          description: 'Chỉ lau rửa nhẹ bằng nước muối sinh lý vô trùng hoặc nước mát sạch.',
          iconName: 'water_drop',
        ),
        RoutineStep(
          title: 'Tuyệt đối không cạy gãi',
          description: 'Không cạy, chọc kim hoặc bóc vảy tổn thương để tránh di căn hay bội nhiễm.',
          iconName: 'do_not_touch',
          isWarning: true,
        ),
      ],
      recommendedProducts: [
        ProductRecommendation(
          category: 'Cơ sở Y tế đề xuất',
          brandAndName: 'Bệnh viện Da liễu Trung ương / TP.HCM',
          reason: 'Cơ sở đầu khoa có đầy đủ thiết bị sinh thiết da chẩn đoán chính xác nhất.',
        ),
      ],
    );
  }

  // ==========================================================
  // BƯỚC 1: LÀM SẠCH BAN SÁNG (TÙY BIẾN THEO LOẠI DA)
  // ==========================================================
  if (safeProfile.skinType == 'Oily') {
    morning.add(RoutineStep(
      title: 'Làm sạch kiềm dầu',
      description: 'Rửa mặt bằng sữa rửa mặt dạng tạo bọt mỏng giúp kiểm soát bã nhờn dư thừa sau một đêm ngủ.',
      iconName: 'water_drop',
    ));
  } else {
    morning.add(RoutineStep(
      title: 'Làm sạch dịu nhẹ',
      description: 'Rửa mặt bằng nước mát sạch hoặc sữa rửa mặt dạng sữa không bọt bảo vệ độ ẩm tự nhiên của da.',
      iconName: 'water_drop',
    ));
  }

  // ==========================================================
  // BƯỚC 2: TIẾN TRÌNH ĐẶC TRỊ THEO CỤM BỆNH
  // ==========================================================
  switch (family) {
    case PathologicalFamily.inflammatory:
      recommends.addAll(['Niacinamide (B3)', 'Salicylic Acid (BHA)', 'Zinc PCA']);
      avoids.addAll(['Dầu dừa', 'Hương liệu nhân tạo (Fragrance)', 'Cồn khô']);
      
      morning.add(RoutineStep(
        title: 'Kháng viêm dịu da',
        description: 'Bôi một lớp mỏng Serum Niacinamide giúp kiểm soát bã nhờn, kháng viêm giảm các nốt đỏ.',
        iconName: 'spa',
      ));
      
      evening.add(RoutineStep(
        title: 'Tẩy trang dịu nhẹ',
        description: 'Dùng nước tẩy trang Micellar Water lành tính không chứa cồn để hòa tan kem chống nắng.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Rửa mặt sạch sâu',
        description: 'Rửa mặt bằng sữa rửa mặt chứa BHA để len lỏi sâu làm thông thoáng lỗ chân lông.',
        iconName: 'water_drop',
      ));

      if (safeProfile.isSensitive) {
        evening.add(RoutineStep(
          title: 'Kháng khuẩn rau má',
          description: 'Thoa tinh chất làm dịu chiết xuất Centella Asiatica để làm dịu các nốt mụn viêm sưng.',
          iconName: 'science',
        ));
      } else {
        evening.add(RoutineStep(
          title: 'Chấm mụn đặc trị',
          description: 'Chấm một lớp mỏng chứa Benzoyl Peroxide hoặc BHA 2% trực tiếp lên đầu mụn sưng đỏ.',
          iconName: 'science',
        ));
      }
      
      evening.add(RoutineStep(
        title: 'Cảnh báo tự ý nặn',
        description: 'Tuyệt đối không tự ý nặn mụn viêm bằng tay bẩn để tránh nhiễm trùng lan rộng và tạo sẹo rỗ.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));

      products.addAll([
        ProductRecommendation(
          category: 'Đặc trị',
          brandAndName: 'Paula\'s Choice 2% BHA Liquid Exfoliant',
          reason: 'Làm sạch sâu bã nhờn bít tắc trong nang lông, đẩy lùi mụn ẩn.',
        ),
        ProductRecommendation(
          category: 'Dưỡng ẩm',
          brandAndName: 'La Roche-Posay Effaclar Duo+',
          reason: 'Hỗ trợ giảm mụn viêm, ngừa vết thâm sau mụn cực tốt.',
        ),
      ]);
      break;

    case PathologicalFamily.eczematous:
      recommends.addAll(['Ceramides', 'Panthenol (B5)', 'Glycerin']);
      avoids.addAll(['Chất tạo bọt SLS/SLES', 'Hương liệu', 'Nước rửa quá nóng']);

      morning.add(RoutineStep(
        title: 'Cấp ẩm tức thì',
        description: 'Thoa kem dưỡng ẩm chứa Ceramides và B5 ngay khi da còn ẩm để giữ nước tuyệt đối.',
        iconName: 'spa',
      ));

      evening.add(RoutineStep(
        title: 'Lau sạch nhẹ nhàng',
        description: 'Dùng bông cotton mềm thấm nước muối sinh lý hoặc tẩy trang dành riêng cho da nhạy cảm cực hạn.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Bổ sung màng khóa ẩm',
        description: 'Bôi lớp kem dưỡng phục hồi hàng rào lipid dày hơn ban ngày trước khi ngủ để tránh da nứt nẻ.',
        iconName: 'nightlight_round',
      ));
      evening.add(RoutineStep(
        title: 'Chống cào xước',
        description: 'Nếu vùng da chàm quá ngứa, hãy chườm mát dịu da. Tuyệt đối không gãi làm trầy xước rách da.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));

      products.addAll([
        ProductRecommendation(
          category: 'Dưỡng ẩm',
          brandAndName: 'La Roche-Posay Cicaplast Baume B5',
          reason: 'Chứa 5% Panthenol giúp làm dịu ngứa, thúc đẩy phục hồi da chàm nứt nẻ nhanh chóng.',
        ),
        ProductRecommendation(
          category: 'Làm sạch',
          brandAndName: 'CeraVe Hydrating Cleanser',
          reason: 'Không tạo bọt, chứa 3 loại Ceramides thiết yếu giữ màng ẩm nguyên vẹn.',
        ),
      ]);
      break;

    case PathologicalFamily.fungal:
      recommends.addAll(['Ketoconazole', 'Tea Tree Oil (Tràm trà)']);
      avoids.addAll(['Kem dưỡng ẩm quá dày dạng Cream bít tắc', 'Quần áo bó chặt giữ mồ hôi']);

      morning.add(RoutineStep(
        title: 'Làm sạch & Giữ khô thoáng',
        description: 'Rửa sạch da bằng sữa rửa mặt kháng khuẩn và dùng khăn giấy dùng 1 lần lau thật khô ráo.',
        iconName: 'water_drop',
      ));
      morning.add(RoutineStep(
        title: 'Thoa hoạt chất kháng nấm',
        description: 'Thoa một lớp mỏng thuốc bôi kháng nấm (như Ketoconazole) theo chỉ định y khoa.',
        iconName: 'science',
      ));

      evening.add(RoutineStep(
        title: 'Vệ sinh vùng bệnh',
        description: 'Rửa sạch da bằng nước ấm nhẹ, không ngâm nước quá lâu.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Thoa thuốc kháng nấm tối',
        description: 'Bôi lớp thuốc đặc trị nấm phủ đều lên rìa vết nấm.',
        iconName: 'science',
      ));
      evening.add(RoutineStep(
        title: 'Tránh đắp ẩm bít da',
        description: 'Không thoa dầu dưỡng hoặc kem khóa ẩm quá đặc lên vùng da bị nấm vì nấm cực kỳ ưa môi trường dầu ẩm.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));

      products.addAll([
        ProductRecommendation(
          category: 'Thuốc bôi (Y khoa)',
          brandAndName: 'Kem bôi chứa Ketoconazole 2%',
          reason: 'Ức chế sự phát triển sinh sôi của tế bào nấm sợi ngoài da.',
        ),
      ]);
      break;

    case PathologicalFamily.bacterial:
      recommends.addAll(['Mupirocin', 'Dung dịch sát khuẩn Povidone-Iodine']);
      avoids.addAll(['Tự ý nặn mủ', 'Băng kín vết thương quá chặt']);

      morning.add(RoutineStep(
        title: 'Sát trùng nhẹ nhàng',
        description: 'Dùng bông gạc thấm nước muối sinh lý lau nhẹ vùng chốc lở/viêm mô tế bào để loại bỏ dịch mủ khô.',
        iconName: 'water_drop',
      ));
      morning.add(RoutineStep(
        title: 'Bôi kháng sinh tại chỗ',
        description: 'Thoa một lớp mỏng thuốc mỡ kháng sinh (như Axit Fusidic hoặc Mupirocin) theo chỉ dẫn.',
        iconName: 'science',
      ));

      evening.add(RoutineStep(
        title: 'Vệ sinh vô trùng',
        description: 'Rửa vết thương nhẹ nhàng bằng dung dịch sát khuẩn y tế pha loãng.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Thoa kháng sinh ban đêm',
        description: 'Thoa lại thuốc mỡ kháng sinh để bảo vệ vết thương suốt đêm ngủ.',
        iconName: 'science',
      ));
      evening.add(RoutineStep(
        title: 'Không cạy cạp vảy mủ',
        description: 'Tuyệt đối không cạy vảy vàng hoặc nặn mủ chảy ra tránh làm vi khuẩn lan sâu vào máu.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));

      products.addAll([
        ProductRecommendation(
          category: 'Kháng sinh bôi',
          brandAndName: 'Thuốc mỡ Fucidin (Axit Fusidic)',
          reason: 'Kháng sinh tại chỗ hiệu quả cực cao chống lại vi khuẩn tụ cầu vàng gây chốc lở.',
        ),
      ]);
      break;

    case PathologicalFamily.viral:
      recommends.addAll(['Acyclovir', 'Zinc Oxide (Kẽm Oxit làm dịu)']);
      avoids.addAll(['Đắp lá thuốc nam tự chế', 'Làm vỡ bong bóng nước']);

      morning.add(RoutineStep(
        title: 'Làm sạch xoa dịu',
        description: 'Vệ sinh nhẹ bằng nước muối sinh lý ấm, thấm khô bằng gạc mềm sạch vô trùng.',
        iconName: 'water_drop',
      ));
      morning.add(RoutineStep(
        title: 'Bôi Acyclovir sớm',
        description: 'Thoa thuốc kháng virus Acyclovir càng sớm càng tốt (đặc biệt trong 72 giờ đầu phát bệnh).',
        iconName: 'science',
      ));

      evening.add(RoutineStep(
        title: 'Rửa nhẹ giảm rát',
        description: 'Vệ sinh cơ bản, không để nước xối trực tiếp mạnh vào chùm mụn nước rộp.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Bôi Acyclovir ban đêm',
        description: 'Thoa lại thuốc kháng virus giúp hạn chế virus nhân bản trong đêm.',
        iconName: 'science',
      ));
      evening.add(RoutineStep(
        title: 'Cấm làm vỡ mụn nước',
        description: 'Không cọ xát, không dùng kim chọc vỡ các bóng nước để tránh virus lây lan sang các vùng da lành bên cạnh.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));
      break;

    case PathologicalFamily.parasitic:
      recommends.addAll(['Permethrin', 'Lưu huỳnh nồng độ nhẹ']);
      avoids.addAll(['Gãi xước gây nhiễm trùng thứ phát']);

      morning.add(RoutineStep(
        title: 'Giảm ngứa dịu đỏ',
        description: 'Bôi gel lô hội nguyên chất hoặc Calamine lotion để xoa dịu cơn ngứa ran.',
        iconName: 'spa',
      ));

      evening.add(RoutineStep(
        title: 'Tắm xà phòng diệt khuẩn',
        description: 'Tắm rửa kỹ toàn thân bằng xà phòng diệt khuẩn y khoa.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Thoa Permethrin toàn thân',
        description: 'Bôi thuốc đặc trị ký sinh trùng Permethrin 5% từ cổ xuống chân theo phác đồ bác sĩ.',
        iconName: 'science',
      ));
      evening.add(RoutineStep(
        title: 'Vệ sinh ga chăn màn',
        description: 'Giặt sạch toàn bộ quần áo, ga giường bằng nước nóng > 60 độ C và là ủi nóng để diệt tận gốc trứng ký sinh trùng.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));
      break;

    case PathologicalFamily.pigmentary:
      recommends.addAll(['Vitamin C', 'Alpha Arbutin', 'Axit Kojic', 'Retinoids']);
      avoids.addAll(['Ánh nắng mặt trời trực tiếp', 'Các liệu pháp lột tẩy da cấp tốc chứa corticoid']);

      morning.add(RoutineStep(
        title: 'Ức chế thâm nám sạm',
        description: 'Thoa tinh chất Vitamin C giúp chống oxy hóa và ức chế enzyme tổng hợp hắc sắc tố Melanin.',
        iconName: 'spa',
      ));

      evening.add(RoutineStep(
        title: 'Làm sạch kép cuối ngày',
        description: 'Tẩy trang dầu/nước kỹ lưỡng kết hợp sữa rửa mặt làm sáng da dịu nhẹ.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Tái sinh thúc sừng hóa',
        description: 'Thoa tinh chất chứa Retinol nồng độ thấp hoặc AHA giúp bong nhẹ tế bào sừng thâm sạm bên ngoài.',
        iconName: 'science',
      ));
      evening.add(RoutineStep(
        title: 'Nuôi dưỡng khóa ẩm',
        description: 'Kem dưỡng chứa Niacinamide làm sáng khỏe, củng cố rào bảo vệ.',
        iconName: 'spa',
      ));

      products.addAll([
        ProductRecommendation(
          category: 'Chống oxy hóa',
          brandAndName: 'La Roche-Posay Pure Vitamin C10 Serum',
          reason: 'Chứa 10% Vitamin C nguyên chất giúp làm đều màu da và kích thích collagen.',
        ),
        ProductRecommendation(
          category: 'Tái tạo da',
          brandAndName: 'Obagi Clinical Retinol 0.5% Retexturizing Cream',
          reason: 'Hỗ trợ thúc đẩy chu kỳ thay da sinh học, làm mờ nhanh các vết sạm nám.',
        ),
      ]);
      break;

    case PathologicalFamily.autoimmune:
      recommends.addAll(['Urea', 'Axit Salicylic bóc sừng', 'Ceramides']);
      avoids.addAll(['Căng thẳng (Stress)', 'Rượu bia chất kích thích làm bùng phát']);

      morning.add(RoutineStep(
        title: 'Bóc sừng làm mềm da',
        description: 'Thoa kem dưỡng ẩm chứa hoạt chất bóc sừng dịu nhẹ (Urea 10% hoặc Lactic Acid) để làm láng mảng sừng dày vảy nến.',
        iconName: 'spa',
      ));

      evening.add(RoutineStep(
        title: 'Vệ sinh nhẹ nhàng',
        description: 'Lau rửa nhẹ bằng nước ấm, tránh cọ chà mạnh làm tổn thương da nặng thêm (hiện tượng Koebner).',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Khóa nước tối ưu',
        description: 'Kem dưỡng ẩm cực kỳ đậm đặc dạng Ointment/Cream bảo vệ màng ẩm.',
        iconName: 'nightlight_round',
      ));
      evening.add(RoutineStep(
        title: 'Không cạy mảng vảy nến',
        description: 'Không cạy các vảy sừng sần sùi bám chặt trên da để tránh xước máu gây viêm da lan tỏa rộng.',
        iconName: 'do_not_touch',
        isWarning: true,
      ));
      break;

    case PathologicalFamily.benign:
      recommends.addAll(['Dưỡng ẩm cơ bản', 'Kem chống nắng chống thoái hóa tế bào']);
      avoids.addAll(['Tự ý dùng axit hoặc cạy đốt cháy nốt ruồi tại nhà']);

      morning.add(RoutineStep(
        title: 'Dưỡng ẩm cơ bản',
        description: 'Thoa lớp kem dưỡng ẩm mỏng nhẹ giúp da mịn màng khỏe mạnh.',
        iconName: 'spa',
      ));

      evening.add(RoutineStep(
        title: 'Vệ sinh da lành tính',
        description: 'Tẩy trang dịu nhẹ và rửa sạch mặt để đào thải bã nhờn bụi bẩn tích tụ.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Dưỡng phục hồi dịu nhẹ',
        description: 'Bôi kem dưỡng ẩm dịu nhẹ ban đêm củng cố độ ẩm.',
        iconName: 'nightlight_round',
      ));
      break;

    case PathologicalFamily.healthy:
      recommends.addAll(['Hyaluronic Acid', 'Vitamin C', 'Ceramides']);
      avoids.addAll(['Tẩy da chết cơ học quá mạnh', 'Mỹ phẩm trôi nổi không rõ nguồn gốc']);

      morning.add(RoutineStep(
        title: 'Cấp ẩm HA mỏng nhẹ',
        description: 'Thoa tinh chất/serum chứa Hyaluronic Acid làm căng mọng làn da.',
        iconName: 'spa',
      ));

      evening.add(RoutineStep(
        title: 'Làm sạch tối',
        description: 'Tẩy trang Micellar dịu nhẹ loại bỏ lớp bụi bẩn ô nhiễm.',
        iconName: 'cleaning_services',
      ));
      evening.add(RoutineStep(
        title: 'Khóa ẩm phục hồi',
        description: 'Dùng kem dưỡng phục hồi củng cố độ đàn hồi, ngăn ngừa lão hóa sớm.',
        iconName: 'nightlight_round',
      ));
      break;
    case PathologicalFamily.critical:
      break;
  }

  // ==========================================================
  // BƯỚC 3: BẢO VỆ CHỐNG NẮNG CHO MỌI ROUTINE SÁNG TRỪ CRITICAL
  // ==========================================================
  if (family != PathologicalFamily.critical) {
    if (safeProfile.skinType == 'Oily') {
      morning.add(RoutineStep(
        title: 'Chống nắng ráo mịn',
        description: 'Bôi kem chống nắng phổ rộng dạng Fluid/Gel ráo nhẹ, không chứa dầu, không gây bít tắc chân lông.',
        iconName: 'wb_sunny',
      ));
    } else {
      morning.add(RoutineStep(
        title: 'Chống nắng dưỡng ẩm',
        description: 'Thoa kem chống nắng quang phổ rộng SPF50+ giàu màng ẩm bảo vệ da khô khỏi mất nước bong tróc.',
        iconName: 'wb_sunny',
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

/// Hàm hỗ trợ có tính tương thích ngược cao, tự động lấy phác đồ động cho bệnh lý bằng SkinProfile mặc định.
SkinRoutine getRoutineForDisease(String? aiDiseaseName) {
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
