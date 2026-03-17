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
      latestConfidence.value = (latestDoc['confidence'] ?? 0.0) * 100;

      DateTime date = _parseDate(latestDoc['date']);
      latestDate.value = DateFormat('dd/MM/yyyy, HH:mm').format(date);

      // Thuật toán so sánh trạng thái:
      if (snapshot.docs.length > 1) {
        var prevDoc = snapshot.docs[1].data() as Map<String, dynamic>;
        double prevConf = (prevDoc['confidence'] ?? 0.0) * 100;

        if (latestDisease.value.contains('Normal') || latestDisease.value.contains('Bình thường')) {
          latestStatus.value = 'Tuyệt vời';
        } else {
          // Nếu phần trăm bệnh giảm -> Cải thiện. Nếu tăng -> Cần chú ý
          latestStatus.value = latestConfidence.value < prevConf ? 'Cải thiện' : 'Cần chú ý';
        }
      } else {
        latestStatus.value = 'Mới ghi nhận';
      }

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
      Map<int, List<double>> monthScores = {};

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        DateTime docDate = _parseDate(data['date']);
        int month = docDate.month;

        String dName = data['diseaseName'] ?? '';
        double conf = data['confidence'] ?? 0.0;

        // Công thức tính điểm sức khỏe:
        // Da bình thường = 100đ. Có bệnh = 100 - (Phần trăm bệnh).
        double score = 100.0;
        if (!dName.contains('Normal') && !dName.contains('Bình thường')) {
          score = (100.0 - (conf * 100)).clamp(10.0, 90.0);
        }

        if (!monthScores.containsKey(month)) {
          monthScores[month] = [];
        }
        monthScores[month]!.add(score); // Gom điểm vào đúng tháng
      }

      // Vẽ FlSpot (Tính trung bình điểm của từng tháng)
      List<FlSpot> spots = [];
      var sortedMonths = monthScores.keys.toList()..sort();

      for (int m in sortedMonths) {
        double avgScore = monthScores[m]!.reduce((a, b) => a + b) / monthScores[m]!.length;
        spots.add(FlSpot(m.toDouble(), avgScore)); // Trục X là tháng (1-12), Y là điểm (0-100)
      }

      // Biểu đồ đường cần ít nhất 2 điểm để vẽ, nếu user mới quét 1 tháng, ta nhân đôi điểm đó lên
      if (spots.length == 1) {
        spots.insert(0, FlSpot(spots[0].x - 0.5, spots[0].y));
      }

      // Gán vào biến UI (Chỉ lấy 6 tháng gần nhất cho đỡ rối mắt)
      if (spots.length > 6) {
        trendData.value = spots.sublist(spots.length - 6);
      } else {
        trendData.value = spots;
      }
    });
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