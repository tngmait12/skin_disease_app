enum PathologicalFamily {
  inflammatory, // Viêm & Tuyến bã (Mụn, Rosacea, Phát ban...)
  eczematous,   // Chàm & Viêm da tiếp xúc
  fungal,       // Nhiễm trùng nấm (Hắc lào, Lang ben, nấm móng...)
  bacterial,    // Nhiễm trùng vi khuẩn (Chốc lở, Viêm mô tế bào...)
  viral,        // Nhiễm trùng virus (Zona, Thủy đậu, Mụn cóc...)
  parasitic,    // Ghẻ, ký sinh trùng di chuyển
  pigmentary,   // Sắc tố, rụng tóc & rối loạn toàn thân khác
  autoimmune,   // Bệnh tự miễn (Vảy nến, Lichen phẳng...)
  benign,       // U lành tính (Dày sừng tiết bã, U mạch máu...)
  critical,     // BÁO ĐỘNG ĐỎ: Nghi ngờ Ác tính (Melanoma, BCC, Ung thư...)
  healthy,      // Da khỏe mạnh
}

/// Bảng ánh xạ 35 đầu ra nhãn thô của AI Model sang các Cụm bệnh lý da liễu tương ứng.
const Map<String, PathologicalFamily> diseaseFamilyMap = {
  'Mụn trứng cá và Chứng đỏ mặt (Acne And Rosacea Photos)': PathologicalFamily.inflammatory,
  'Dày sừng quang hóa, Ung thư biểu mô tế bào đáy và các Tổn thương ác tính khác (Actinic Keratosis Basal Cell Carcinoma And Other Malignant Lesions)': PathologicalFamily.critical,
  'Viêm da cơ địa (Atopic Dermatitis Photos)': PathologicalFamily.eczematous,
  'Viêm mô tế bào (Ba Cellulitis)': PathologicalFamily.bacterial,
  'Chốc lở (Ba Impetigo)': PathologicalFamily.bacterial,
  'U da lành tính (Benign)': PathologicalFamily.benign,
  'Bệnh da bọng nước (Bullous Disease Photos)': PathologicalFamily.pigmentary,
  'Viêm mô tế bào, Chốc lở và các bệnh Nhiễm trùng vi khuẩn khác (Cellulitis Impetigo And Other Bacterial Infections)': PathologicalFamily.bacterial,
  'Chàm / Eczema (Eczema Photos)': PathologicalFamily.eczematous,
  'Phát ban và Dị ứng thuốc (Exanthems And Drug Eruptions)': PathologicalFamily.inflammatory,
  'Nấm kẽ chân (Fu Athlete Foot)': PathologicalFamily.fungal,
  'Nấm móng (Fu Nail Fungus)': PathologicalFamily.fungal,
  'Nấm da / Hắc lào (Fu Ringworm)': PathologicalFamily.fungal,
  'Rụng tóc, Hói và các bệnh về Tóc khác (Hair Loss Photos Alopecia And Other Hair Diseases)': PathologicalFamily.pigmentary,
  'Da khỏe mạnh (Heathy)': PathologicalFamily.healthy,
  'Herpes, HPV và các bệnh lây truyền qua đường tình dục (Herpes Hpv And Other Stds Photos)': PathologicalFamily.viral,
  'Bệnh do ánh sáng và Rối loạn sắc tố (Light Diseases And Disorders Of Pigmentation)': PathologicalFamily.pigmentary,
  'Lupus và các bệnh Mô liên kết khác (Lupus And Other Connective Tissue Diseases)': PathologicalFamily.pigmentary,
  'Tổn thương ác tính (Malignant)': PathologicalFamily.critical,
  'Ung thư hắc tố, Ung thư da và Nốt ruồi (Melanoma Skin Cancer Nevi And Moles)': PathologicalFamily.critical,
  'Nấm móng và các bệnh về Móng khác (Nail Fungus And Other Nail Disease)': PathologicalFamily.fungal,
  'Ấu trùng di chuyển dưới da (Pa Cutaneous Larva Migrans)': PathologicalFamily.parasitic,
  'Viêm da tiếp xúc (do cây thường xuân...) (Poison Ivy Photos And Other Contact Dermatitis)': PathologicalFamily.eczematous,
  'Vảy nến, Lichen phẳng và các bệnh liên quan (Psoriasis Pictures Lichen Planus And Related Diseases)': PathologicalFamily.autoimmune,
  'Phát ban da (Rashes)': PathologicalFamily.inflammatory,
  'Ghẻ, bệnh Lyme, các bệnh do Côn trùng cắn & Ký sinh trùng (Scabies Lyme Disease And Other Infestations And Bites)': PathologicalFamily.parasitic,
  'Dày sừng tiết bã và các khối U lành tính khác (Seborrheic Keratoses And Other Benign Tumors)': PathologicalFamily.benign,
  'Bệnh hệ thống có biểu hiện da (Systemic Disease)': PathologicalFamily.pigmentary,
  'Nấm da, Hắc lào, Nhiễm nấm Candida và các bệnh Nhiễm nấm khác (Tinea Ringworm Candidiasis And Other Fungal Infections)': PathologicalFamily.fungal,
  'Mề đay / Phát ban (Urticaria Hives)': PathologicalFamily.inflammatory,
  'U mạch máu (Vascular Tumors)': PathologicalFamily.benign,
  'Viêm mạch máu (Vasculitis Photos)': PathologicalFamily.eczematous,
  'Thủy đậu (Vi Chickenpox)': PathologicalFamily.viral,
  'Zona thần kinh (Vi Shingles)': PathologicalFamily.viral,
  'Mụn cóc, U mềm lây và các bệnh Nhiễm virus khác (Warts Molluscum And Other Viral Infections)': PathologicalFamily.viral,
};

/// Mô tả tiếng Việt thân thiện tương ứng cho các nhãn thô của mô hình AI.
const Map<String, String> diseaseVietnameseNames = {
  'Mụn trứng cá và Chứng đỏ mặt (Acne And Rosacea Photos)': 'Mụn trứng cá & Chứng đỏ mặt',
  'Dày sừng quang hóa, Ung thư biểu mô tế bào đáy và các Tổn thương ác tính khác (Actinic Keratosis Basal Cell Carcinoma And Other Malignant Lesions)': 'Nghi ngờ Tổn thương Ác tính (Báo động đỏ)',
  'Viêm da cơ địa (Atopic Dermatitis Photos)': 'Viêm da cơ địa / Chàm sữa',
  'Viêm mô tế bào (Ba Cellulitis)': 'Viêm mô tế bào',
  'Chốc lở (Ba Impetigo)': 'Bệnh chốc lở da',
  'U da lành tính (Benign)': 'U lành tính trên da',
  'Bệnh da bọng nước (Bullous Disease Photos)': 'Bệnh da bọng nước',
  'Viêm mô tế bào, Chốc lở và các bệnh Nhiễm trùng vi khuẩn khác (Cellulitis Impetigo And Other Bacterial Infections)': 'Nhiễm trùng da do vi khuẩn',
  'Chàm / Eczema (Eczema Photos)': 'Bệnh chàm / Eczema',
  'Phát ban và Dị ứng thuốc (Exanthems And Drug Eruptions)': 'Phát ban hoặc Dị ứng thuốc bôi',
  'Nấm kẽ chân (Fu Athlete Foot)': 'Nấm kẽ chân (Nước ăn chân)',
  'Nấm móng (Fu Nail Fungus)': 'Nấm móng tay / móng chân',
  'Nấm da / Hắc lào (Fu Ringworm)': 'Hắc lào / Lác đồng tiền',
  'Rụng tóc, Hói và các bệnh về Tóc khác (Hair Loss Photos Alopecia And Other Hair Diseases)': 'Rụng tóc / Hói đầu / Bệnh lý về tóc',
  'Da khỏe mạnh (Heathy)': 'Da khỏe mạnh bình thường',
  'Herpes, HPV và các bệnh lây truyền qua đường tình dục (Herpes Hpv And Other Stds Photos)': 'Nhiễm Herpes / HPV sùi mào gà',
  'Bệnh do ánh sáng và Rối loạn sắc tố (Light Diseases And Disorders Of Pigmentation)': 'Rối loạn sắc tố da (Nám, tàn nhang)',
  'Lupus và các bệnh Mô liên kết khác (Lupus And Other Connective Tissue Diseases)': 'Bệnh Lupus ban đỏ hệ thống',
  'Tổn thương ác tính (Malignant)': 'Nghi ngờ Tổn thương Ác tính (Khẩn cấp)',
  'Ung thư hắc tố, Ung thư da và Nốt ruồi (Melanoma Skin Cancer Nevi And Moles)': 'Ung thư da Melanoma / Nốt ruồi ác tính',
  'Nấm móng và các bệnh về Móng khác (Nail Fungus And Other Nail Disease)': 'Nấm móng & Bệnh lý về móng',
  'Ấu trùng di chuyển dưới da (Pa Cutaneous Larva Migrans)': 'Ấu trùng di chuyển dưới da (Ký sinh trùng)',
  'Viêm da tiếp xúc (do cây thường xuân...) (Poison Ivy Photos And Other Contact Dermatitis)': 'Viêm da tiếp xúc kích ứng',
  'Vảy nến, Lichen phẳng và các bệnh liên quan (Psoriasis Pictures Lichen Planus And Related Diseases)': 'Vảy nến / Lichen phẳng',
  'Phát ban da (Rashes)': 'Phát ban da mẩn đỏ',
  'Ghẻ, bệnh Lyme, các bệnh do Côn trùng cắn & Ký sinh trùng (Scabies Lyme Disease And Other Infestations And Bites)': 'Bệnh ghẻ nước / Côn trùng cắn',
  'Dày sừng tiết bã và các khối U lành tính khác (Seborrheic Keratoses And Other Benign Tumors)': 'Dày sừng tiết bã / Khối u da lành tính',
  'Bệnh hệ thống có biểu hiện da (Systemic Disease)': 'Biểu hiện ngoài da của bệnh hệ thống',
  'Nấm da, Hắc lào, Nhiễm nấm Candida và các bệnh Nhiễm nấm khác (Tinea Ringworm Candidiasis And Other Fungal Infections)': 'Nhiễm nấm ngoài da (Candida/Tinea)',
  'Mề đay / Phát ban (Urticaria Hives)': 'Mề đay mẩn ngứa / Phát ban cát',
  'U mạch máu (Vascular Tumors)': 'Khối u mạch máu lành tính',
  'Viêm mạch máu (Vasculitis Photos)': 'Bệnh viêm mạch máu hoại tử da',
  'Thủy đậu (Vi Chickenpox)': 'Bệnh thủy đậu (Trái rạ)',
  'Zona thần kinh (Vi Shingles)': 'Bệnh Zona thần kinh (Giời leo)',
  'Mụn cóc, U mềm lây và các bệnh Nhiễm virus khác (Warts Molluscum And Other Viral Infections)': 'Mụn cóc sinh dục / U mềm lây do virus',
};
