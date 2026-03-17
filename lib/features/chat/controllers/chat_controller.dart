import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message.dart';

//Google AI Studio
class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  var isTyping = false.obs;

  ChatSession? _chatSession;
  static const String _apiKey = 'AIzaSyBhxX_Z0FQwQPGmGPbVfeeV9GBlD4J4vGQ';
  @override
  void onInit() {
    super.onInit();
    _initGemini();
    // Gửi sẵn 1 tin nhắn chào mừng khi vừa mở màn hình
    messages.add(
        ChatMessage(
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
        temperature: 0.2,
      ),
      // Da mình đang bị mụn viêm đỏ chót, mình có nên bôi chanh hay kem trộn không?
      systemInstruction: Content.system(
          'Bạn là một chuyên gia tư vấn chăm sóc da liễu thân thiện, chuyên nghiệp và ngắn gọn. '
              'Nhiệm vụ của bạn là giải đáp thắc mắc về các bệnh ngoài da, thành phần mỹ phẩm, '
              'và gợi ý các bước chăm sóc da (Skincare routine) cơ bản. '
              'QUY TẮC TỐI THƯỢNG: Tuyệt đối KHÔNG kê đơn thuốc đặc trị hoặc kháng sinh. '
              'Nếu người dùng mô tả triệu chứng nặng, chảy máu hoặc nhiễm trùng, hãy khuyên họ '
              'ngừng sử dụng mỹ phẩm và đến bệnh viện da liễu ngay lập tức. '
              'Trả lời bằng tiếng Việt tự nhiên, thân thiện và định dạng văn bản rõ ràng bằng các gạch đầu dòng.'
      ),
    );

    // Bắt đầu một phiên chat mới
    _chatSession = model.startChat();
  }

  void sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // 1. Hiển thị tin nhắn của người dùng
    messages.add(ChatMessage(text: text, isUser: true));
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
      messages.add(ChatMessage(text: aiResponseText, isUser: false));

    } catch (e) {
      // Xử lý khi mất mạng hoặc API lỗi
      messages.add(
          ChatMessage(
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