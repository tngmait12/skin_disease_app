import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUserId {
    return Get.find<AuthController>().currentUserId.value;
  }

  // 1. Current Status (Lấy lần quét gần nhất)
  final RxString latestDisease = 'Chưa có dữ liệu'.obs;
  final RxString latestDate = '--/--/----'.obs;
  final RxString latestStatus = '-'.obs;
  final RxDouble latestConfidence = 0.0.obs;

  // ==========================================
  // 2. BIỂU ĐỒ XU HƯỚNG (Trend Data)
  // ==========================================
  final RxList<FlSpot> trendData = <FlSpot>[].obs;

  // ==========================================
  // 3. THỐNG KÊ BỆNH LÝ (Conditions Breakdown)
  // ==========================================
  final RxMap<String, double> conditionsData = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (currentUserId.isNotEmpty) {
      _listenToDashboardData();
    }
  }

  // HÀM LẮNG NGHE DỮ LIỆU TỪ FIRESTORE (Real-time)
  void _listenToDashboardData() {
    _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('scan_history')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {

      if (snapshot.docs.isEmpty) {
        _resetData();
        return;
      }

      // ---------------------------------------------------------
      // PHẦN A: XỬ LÝ LẦN QUÉT GẦN NHẤT
      // ---------------------------------------------------------
      var latestDoc = snapshot.docs.first.data() as Map<String, dynamic>;
      latestDisease.value = latestDoc['diseaseName'] ?? 'Không xác định';
      latestConfidence.value = (latestDoc['confidence'] ?? 0.0);

      DateTime date = _parseDate(latestDoc['date']);
      latestDate.value = DateFormat('dd/MM/yyyy, HH:mm').format(date);

      double latestWeight = getWeight(latestDisease.value);
      latestStatus.value = getDiseaseStatusGroup(latestWeight);

      // ---------------------------------------------------------
      // PHẦN B: ĐẾM SỐ LƯỢNG BỆNH LÝ (Pie Chart)
      // ---------------------------------------------------------
      Map<String, double> tempConditions = {};
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String disease = data['diseaseName'] ?? 'Khác';
        tempConditions[disease] = (tempConditions[disease] ?? 0) + 1;
      }
      conditionsData.value = tempConditions;

      // ---------------------------------------------------------
      // PHẦN C: TÍNH TOÁN ĐIỂM SỨC KHỎE THEO THÁNG (Line Chart)
      // ---------------------------------------------------------

      Map<String, List<double>> dailyScores = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime docDate = _parseDate(data['date']);
        String dayKey = DateFormat('yyyy-MM-dd').format(docDate);

        var rawConfidence = data['confidence'] / 100;

        double score = calculateHealthScore(data['diseaseName'] ?? '', rawConfidence ?? 0.0);

        // Nhét điểm vào đúng "rổ" của ngày hôm đó
        if (!dailyScores.containsKey(dayKey)) {
          dailyScores[dayKey] = [];
        }
        dailyScores[dayKey]!.add(score);
      }

      // Bước 2: Sắp xếp các ngày theo thứ tự từ quá khứ đến hiện tại
      var sortedDays = dailyScores.keys.toList()..sort();

      // Chỉ lấy 7 ngày có quét da gần nhất để biểu đồ không bị nát
      if (sortedDays.length > 7) {
        sortedDays = sortedDays.sublist(sortedDays.length - 7);
      }

      // Bước 3: Vẽ FlSpot
      List<FlSpot> spots = [];

      for (int i = 0; i < sortedDays.length; i++) {
        String dayStr = sortedDays[i];
        // Tính trung bình cộng nếu 1 ngày user quét 2, 3 lần
        double rawAvg = dailyScores[dayStr]!.fold(0.0, (a, b) => a + b) / dailyScores[dayStr]!.length;
        double avgScore = double.parse(rawAvg.toStringAsFixed(1));

        // Trích xuất lấy đúng con số của "Ngày" để làm trục X (Ví dụ: Ngày 18 -> X = 18.0)
        DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dayStr);
        spots.add(FlSpot(parsedDate.day.toDouble(), avgScore));
      }

      // Mẹo nhỏ: Nếu user mới tải app và chỉ quét đúng 1 ngày, biểu đồ đường sẽ lỗi vì nó cần 2 điểm để nối đoạn thẳng.
      // Ta tự động tạo 1 điểm "ảo" lùi lại 1 ngày trước đó với cùng điểm số để nối tia.
      if (spots.length == 1) {
        spots.insert(0, FlSpot(spots[0].x - 1, spots[0].y));
      }

      trendData.assignAll(spots);
    });
  }

  // ==========================================
  // BỘ TỪ ĐIỂN Y KHOA & HÀM HỖ TRỢ
  // ==========================================
  final Map<String, double> severityWeights = {
    'Melanoma': 0.95, 'Basal Cell Carcinoma': 0.90, 'Malignant': 0.90,
    'Lupus': 0.85, 'Systemic Disease': 0.80, 'Bullous Disease': 0.80,
    'Vasculitis': 0.75, 'Drug Eruptions': 0.75,
    'Cellulitis': 0.65, 'Shingles': 0.65, 'Herpes': 0.60, 'Stds': 0.60,
    'Psoriasis': 0.55, 'Eczema': 0.50, 'Atopic Dermatitis': 0.50,
    'Contact Dermatitis': 0.45, 'Impetigo': 0.45, 'Chickenpox': 0.45,
    'Scabies': 0.40, 'Lyme Disease': 0.40, 'Ringworm': 0.35, 'Tinea': 0.35,
    'Nail Fungus': 0.35, 'Athlete Foot': 0.35, 'Candidiasis': 0.35, 'Larva Migrans': 0.35,
    'Acne': 0.25, 'Rosacea': 0.25, 'Warts': 0.25, 'Molluscum': 0.25, 'Urticaria': 0.20,
    'Rashes': 0.20, 'Exanthems': 0.20, 'Hair Loss': 0.15, 'Alopecia': 0.15,
    'Pigmentation': 0.10, 'Benign': 0.10, 'Vascular Tumors': 0.10, 'Seborrheic Keratoses': 0.10,
    'Heathy': 0.0, 'Healthy': 0.0, 'Normal': 0.0,
  };

  // Hàm nội bộ: Lấy trọng số của bệnh
  double getWeight(String diseaseName) {
    for (var key in severityWeights.keys) {
      if (diseaseName.toLowerCase().contains(key.toLowerCase())) {
        return severityWeights[key]!;
      }
    }
    return 0.5;
  }

  // Hàm nội bộ: Tính điểm sức khỏe an toàn (10.0 -> 100.0)
  double calculateHealthScore(String diseaseName, double confidence) {
    double weight = getWeight(diseaseName);
    return (100.0 - (weight * confidence * 100)).clamp(10.0, 100.0);
  }

  // Hàm nội bộ: Xếp nhóm trạng thái dựa trên mức độ nghiêm trọng
  String getDiseaseStatusGroup(double weight) {
    if (weight >= 0.90) {
      return 'Cực kỳ nguy hiểm'; // Nhóm 1: Ung thư
    } else if (weight >= 0.75) {
      return 'Nghiêm trọng';   // Nhóm 2: Tự miễn, Hệ thống
    } else if (weight >= 0.60) {
      return 'Cấp tính';          // Nhóm 3: Virus, Viêm mô
    } else if (weight >= 0.45) {
      return 'Mãn tính';        // Nhóm 4: Vảy nến, Chàm
    } else if (weight >= 0.35) {
      return 'Nhiễm trùng';      // Nhóm 5: Nấm, Ký sinh trùng
    } else if (weight >= 0.10) {
      return 'Lành tính';     // Nhóm 6: Mụn, Rụng tóc
    } else {
      return 'Da khỏe mạnh';       // Nhóm 7: Bình thường
    }
  }

  // Hàm hỗ trợ parse Date từ Firestore
  DateTime _parseDate(dynamic dateData) {
    if (dateData == null) return DateTime.now();
    if (dateData is Timestamp) return dateData.toDate();
    if (dateData is String) return DateTime.parse(dateData);
    return DateTime.now();
  }

  // Trả UI về mặc định khi Database rỗng
  void _resetData() {
    latestDisease.value = 'Chưa có dữ liệu';
    latestDate.value = '--/--/----';
    latestStatus.value = '-';
    latestConfidence.value = 0.0;

    trendData.value = const [FlSpot(1, 0), FlSpot(2, 0)];

    conditionsData.value = {'Chưa có dữ liệu': 1.0};

    // trendData.clear();
    // conditionsData.clear();
  }

}