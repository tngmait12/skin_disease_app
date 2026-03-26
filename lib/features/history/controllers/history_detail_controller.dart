import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HistoryDetailController extends GetxController {
  final String diseaseName;

  // Các biến quản lý trạng thái
  var isLoading = true.obs;
  var description = ''.obs;
  var causes = <String>[].obs;

  HistoryDetailController({required this.diseaseName});

  @override
  void onInit() {
    super.onInit();
    generateDiseaseInfo();
  }

  Future<void> generateDiseaseInfo() async {
    try {
      isLoading.value = true;

      final apiKey = 'AIzaSyBhxX_Z0FQwQPGmGPbVfeeV9GBlD4J4vGQ';
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

      // Kỹ thuật Prompt Engineering: Ép AI trả về đúng format để dễ tách chuỗi
      final prompt = '''
      Bạn là một bác sĩ da liễu chuyên nghiệp. Bệnh nhân của bạn vừa được chẩn đoán mắc bệnh: "$diseaseName".
      Hãy cung cấp thông tin theo đúng định dạng sau (Không dùng markdown in đậm, in nghiêng):
      MÔ TẢ:
      (Viết 3 câu mô tả ngắn gọn, dễ hiểu về bệnh này)
      NGUYÊN NHÂN:
      - (Nguyên nhân 1)
      - (Nguyên nhân 2)
      - (Nguyên nhân 3)
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      String rawText = response.text ?? '';

      if (rawText.contains('NGUYÊN NHÂN:')) {
        List<String> parts = rawText.split('NGUYÊN NHÂN:');
        description.value = parts[0].replaceAll('MÔ TẢ:', '').trim();

        // Tách các nguyên nhân thành một mảng (List) dựa vào dấu gạch đầu dòng
        List<String> rawCauses = parts[1].split('\n');
        causes.assignAll(
            rawCauses.where((e) => e.trim().startsWith('-')).map((e) => e.replaceAll('-', '').trim()).toList()
        );
      } else {
        description.value = rawText;
      }

    } catch (e) {
      description.value = "Xin lỗi, hệ thống AI hiện không thể cung cấp thông tin. Vui lòng thử lại sau.";
    } finally {
      isLoading.value = false;
    }
  }
}