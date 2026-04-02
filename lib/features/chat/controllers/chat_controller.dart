import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/models/chat_message_model.dart';

//Google AI Studio
class ChatController extends GetxController {
  var messages = <ChatMessageModel>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  var isTyping = false.obs;

  ChatSession? _chatSession;
  static String get _apiKey => dotenv.env['CHAT_API_KEY'] ?? 'Không tìm thấy key';
  @override
  void onInit() {
    super.onInit();
    _initGemini();
    // Gửi sẵn 1 tin nhắn chào mừng khi vừa mở màn hình
    messages.add(
        ChatMessageModel(
          text: "Xin chào! Mình là Trợ lý AI Da liễu. Mình có thể giúp gì cho tình trạng da của bạn hôm nay?",
          isUser: false,
        )
    );
  }

  void _initGemini() {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
      ),
      systemInstruction: Content.system(
          '''Bạn là "Trợ lý Da liễu AI" độc quyền của ứng dụng.
VAI TRÒ: Chuyên gia tư vấn da liễu thân thiện, thấu cảm, có kiến thức khoa học sâu rộng.

ĐỊNH DẠNG PHẢN HỒI BẮT BUỘC (Sử dụng Markdown):
1. CẤU TRÚC: Chia phản hồi thành các đoạn ngắn. Dùng tiêu đề phụ (###) nếu câu trả lời dài.
2. NHẤN MẠNH: Bắt buộc dùng in đậm (**chữ in đậm**) cho Tên bệnh lý, Tên hoạt chất (Ví dụ: **Salicylic Acid**, **Niacinamide**).
3. DANH SÁCH: Sử dụng gạch đầu dòng (-) cho các bước chăm sóc hoặc danh sách liệt kê.
4. TÔN TRỌNG: Mở đầu bằng sự đồng cảm nhẹ nhàng với tình trạng của người dùng.

QUY TẮC Y KHOA TỐI THƯỢNG (KHÔNG ĐƯỢC VI PHẠM):
- TỪ CHỐI kê đơn thuốc Tây, kháng sinh, corticoid dưới mọi hình thức.
- CHỈ GỢI Ý các thành phần mỹ phẩm/dược mỹ phẩm không kê đơn.
- BẮT BUỘC chèn câu này (in nghiêng) ở cuối mỗi câu trả lời: "*Lưu ý y khoa: Thông tin trên chỉ mang tính chất tham khảo. Vui lòng thăm khám bác sĩ da liễu nếu tình trạng không thuyên giảm.*"
- BÁO ĐỘNG ĐỎ: Nếu người dùng nhắc đến chảy máu, mưng mủ nặng, hoặc nghi ngờ ung thư, lập tức yêu cầu họ dừng mọi loại mỹ phẩm và đến bệnh viện ngay.
'''
      ),
    );

    _chatSession = model.startChat();
  }

  void sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. Hiển thị tin nhắn của người dùng
    messages.add(ChatMessageModel(text: text, isUser: true));
    textController.clear();
    _scrollToBottom();

    // 2. Bật trạng thái "AI đang phân tích..."
    isTyping.value = true;
    _scrollToBottom();

    try {
      // 3. Gửi tin nhắn lên server Google Gemini
      if (_chatSession == null) _initGemini();
      final response = await _chatSession!.sendMessage(Content.text(text));

      // Lấy kết quả trả về
      final aiResponseText = response.text ?? "Xin lỗi, mình chưa hiểu rõ ý của bạn. Bạn có thể diễn đạt lại không?";

      // 4. Hiển thị câu trả lời của AI
      messages.add(ChatMessageModel(text: aiResponseText, isUser: false));

    } catch (e) {
      // Xử lý khi mất mạng hoặc API lỗi
      messages.add(
          ChatMessageModel(
            text: "Hệ thống đang bận hoặc mất kết nối mạng. Bạn kiểm tra lại wifi và thử lại nhé!",
            isUser: false,
          )
      );
      print("Lỗi Gemini API: $e");
    } finally {
      // Tắt trạng thái typing
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  // Hàm tự động cuộn xuống tin nhắn mới nhất
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}