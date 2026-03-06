import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardController extends GetxController {
  // 1. Current Status (Lấy lần quét gần nhất)
  final RxString latestDisease = 'Acne (Mụn trứng cá)'.obs;
  final RxString latestDate = 'Hôm nay, 08:30 AM'.obs;
  final RxString latestStatus = 'Cải thiện'.obs; // Hoặc 'Xấu đi', 'Ổn định'

  // 2. Health Score Trend (Dữ liệu cho biểu đồ đường)
  // Giả lập điểm sức khỏe da qua 6 tháng gần nhất (thang điểm 100)
  final List<FlSpot> trendData = const [
    FlSpot(1, 65), // Tháng 1
    FlSpot(2, 55), // Tháng 2 (Giảm do nổi mụn)
    FlSpot(3, 70), // Tháng 3
    FlSpot(4, 80), // Tháng 4
    FlSpot(5, 75), // Tháng 5
    FlSpot(6, 90), // Tháng 6 (Hiện tại)
  ];

  // 3. Conditions Breakdown (Thống kê các loại bệnh đã quét)
  // Giả lập tổng số 20 lần quét
  final Map<String, double> conditionsData = {
    'Acne (Mụn trứng cá)': 12, // 12 lần
    'Normal (Da khỏe)': 5,     // 5 lần
    'Melanoma (Nghi ngờ)': 3,  // 3 lần
  };
}