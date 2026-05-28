import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/scan_model.dart';
import '../../../core/services/local_storage_service.dart';
import '../../auth/controllers/auth_controller.dart';

// Google AI Studio - Trợ lý Da liễu AI Đa phương thức và Luồng
class ChatController extends GetxController {
  var messages = <ChatMessageModel>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  var isTyping = false.obs;

  // Thuộc tính đính kèm nâng cấp
  final ImagePicker _picker = ImagePicker();
  var selectedImagePath = RxnString();
  var selectedScan = Rxn<ScanModel>();
  var savedTips = <Map<String, dynamic>>[].obs;

  ChatSession? _chatSession;
  static String get _apiKey => dotenv.env['CHAT_API_KEY'] ?? 'Không tìm thấy key';

  @override
  void onInit() {
    super.onInit();
    _initGemini();
    _loadMessages();
    _loadSavedTips();

    // Lắng nghe sự thay đổi của currentUserId để tự động tải lại lịch sử chat và sổ tay khi đổi tài khoản
    final AuthController authController = Get.find<AuthController>();
    ever(authController.currentUserId, (String uid) {
      print('🔄 [ChatController] Phát hiện UID thay đổi: $uid. Đang tải lại lịch sử chat...');
      messages.clear();
      savedTips.clear();
      
      _loadMessages();
      _loadSavedTips();
      
      // Khởi tạo lại phiên trò chuyện để xoá sạch ngữ cảnh của user cũ
      _initGemini();
    });
  }

  void _initGemini() {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
      ),
      systemInstruction: Content.system(
          '''Bạn là "Trợ lý Da liễu AI" độc quyền của ứng dụng SkinShield.
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

  // 💡 Tải lịch sử chat từ bộ nhớ máy
  void _loadMessages() {
    try {
      final LocalStorageService storage = Get.find<LocalStorageService>();
      final savedMessages = storage.getChatHistory();
      if (savedMessages.isNotEmpty) {
        messages.addAll(savedMessages);
      } else {
        _setWelcomeMessage();
      }
    } catch (e) {
      print('❌ Lỗi tải lịch sử chat: $e');
      _setWelcomeMessage();
    }
  }

  void _setWelcomeMessage() {
    messages.add(
      ChatMessageModel(
        text: "Xin chào! Mình là Trợ lý AI Da liễu SkinShield. Mình có thể hỗ trợ tư vấn tình trạng da, thành phần mỹ phẩm hoặc phân tích hình ảnh chẩn đoán của bạn. Hôm nay bạn cần trợ giúp gì?",
        isUser: false,
      )
    );
  }

  // 💡 Lưu lịch sử chat xuống bộ nhớ máy
  void _saveMessages() {
    try {
      final LocalStorageService storage = Get.find<LocalStorageService>();
      storage.saveChatHistory(messages);
    } catch (e) {
      print('❌ Lỗi lưu lịch sử chat: $e');
    }
  }

  // 💡 Tải danh sách lời khuyên đã lưu (Sổ tay)
  void _loadSavedTips() {
    try {
      final LocalStorageService storage = Get.find<LocalStorageService>();
      savedTips.assignAll(storage.getSavedTips());
    } catch (e) {
      print('❌ Lỗi tải sổ tay: $e');
    }
  }

  // 💡 Lưu/Hủy lưu mẹo hay vào Sổ tay
  void toggleBookmarkTip(ChatMessageModel msg) {
    try {
      final LocalStorageService storage = Get.find<LocalStorageService>();
      final index = savedTips.indexWhere((element) => element['text'] == msg.text);

      if (index != -1) {
        savedTips.removeAt(index);
        Get.snackbar(
          'Đã gỡ',
          'Đã gỡ lời khuyên khỏi Sổ tay cá nhân',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        savedTips.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': msg.text,
          'timestamp': DateTime.now().toIso8601String(),
        });
        Get.snackbar(
          'Thành công',
          'Đã lưu mẹo chăm sóc vào Sổ tay Da liễu của bạn',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
      storage.saveSavedTips(savedTips);
    } catch (e) {
      print('❌ Lỗi thao tác sổ tay: $e');
    }
  }

  bool isBookmarked(String text) {
    return savedTips.any((element) => element['text'] == text);
  }

  // 💡 Đính kèm ảnh mới (Chụp/Album)
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        selectedImagePath.value = image.path;
        selectedScan.value = null; // Bỏ chọn quét lịch sử nếu chọn ảnh mới
      }
    } catch (e) {
      Get.snackbar('Lỗi đính kèm', 'Không thể mở camera hoặc album: $e');
    }
  }

  // 💡 Đính kèm kết quả quét lịch sử
  void attachScan(ScanModel scan) {
    selectedScan.value = scan;
    selectedImagePath.value = null; // Bỏ chọn ảnh chụp mới nếu chọn quét cũ
    Get.snackbar(
      'Đã đính kèm',
      'Chọn thành công: ${scan.diseaseName}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  // 💡 Hủy bỏ đính kèm hiện tại
  void clearAttachment() {
    selectedImagePath.value = null;
    selectedScan.value = null;
  }

  // 💡 Gửi tin nhắn đa phương thức & streaming phản hồi thời gian thực
  void sendMessage() async {
    final text = textController.text.trim();
    
    // Yêu cầu có nội dung văn bản hoặc hình ảnh đính kèm để gửi đi
    if (text.isEmpty && selectedImagePath.value == null && selectedScan.value == null) return;

    final userText = text.isEmpty ? "Phân tích hình ảnh đính kèm giúp tôi." : text;
    final attachedImagePath = selectedImagePath.value;
    final attachedScan = selectedScan.value;

    // Reset giao diện nhập ngay lập tức để tăng độ mượt mà
    clearAttachment();
    textController.clear();

    // 1. Thêm tin nhắn của User có kèm meta-data của ảnh
    final userMsg = ChatMessageModel(
      text: userText,
      isUser: true,
      localImagePath: attachedImagePath ?? (attachedScan?.localImagePath.isNotEmpty == true ? attachedScan?.localImagePath : null),
      imageUrl: attachedScan?.firebaseImageUrl,
      diseaseName: attachedScan?.diseaseName,
      confidence: attachedScan?.confidence,
    );
    messages.add(userMsg);
    _saveMessages();
    _scrollToBottom();

    // 2. Hiện trạng thái AI đang phân tích
    isTyping.value = true;
    _scrollToBottom();

    // 3. Khởi tạo bong bóng chat AI trống để hứng luồng Stream dữ liệu
    final aiResponseIndex = messages.length;
    messages.add(ChatMessageModel(text: "", isUser: false));
    _scrollToBottom();

    try {
      if (_chatSession == null) _initGemini();

      // Chuẩn bị byte hình ảnh để gửi lên Gemini
      Uint8List? imageBytes;

      if (attachedImagePath != null) {
        final file = File(attachedImagePath);
        if (await file.exists()) {
          imageBytes = await file.readAsBytes();
        }
      } else if (attachedScan != null) {
        // Kiểm tra ảnh offline cục bộ trước
        if (attachedScan.localImagePath.isNotEmpty) {
          final file = File(attachedScan.localImagePath);
          if (await file.exists()) {
            imageBytes = await file.readAsBytes();
          }
        }

        // Nếu offline không tìm thấy, tải ngầm qua đường dẫn đám mây
        if (imageBytes == null && attachedScan.firebaseImageUrl.isNotEmpty && attachedScan.firebaseImageUrl.startsWith('http')) {
          try {
            final response = await http.get(Uri.parse(attachedScan.firebaseImageUrl));
            if (response.statusCode == 200) {
              imageBytes = response.bodyBytes;
            }
          } catch (e) {
            print("❌ Lỗi tải ảnh đám mây về cho Gemini: $e");
          }
        }
      }

      // Xây dựng nội dung lời nhắc (Prompt Text) thông minh
      String promptText = userText;
      if (attachedScan != null) {
        promptText = '''Đây là kết quả chẩn đoán da từ SkinShield của tôi:
- Tên bệnh lý dự đoán: **${attachedScan.diseaseName}**
- Độ tin cậy: **${attachedScan.confidence.toStringAsFixed(2)}%**
- Câu hỏi cần tư vấn sâu thêm về kết quả chẩn đoán này:
$userText''';
      }

      Content content;
      if (imageBytes != null) {
        content = Content.multi([
          TextPart(promptText),
          DataPart('image/jpeg', imageBytes),
        ]);
      } else {
        content = Content.text(promptText);
      }

      // 4. Bắt đầu nhận phản hồi dạng luồng (Streaming)
      final responseStream = _chatSession!.sendMessageStream(content);
      String accumulatedText = "";

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          accumulatedText += chunk.text!;
          // Cập nhật từng từ nhận được lên giao diện
          messages[aiResponseIndex] = ChatMessageModel(
            text: accumulatedText,
            isUser: false,
            timestamp: DateTime.now(),
          );
          messages.refresh();
          _scrollToBottom();
        }
      }

      // Lưu trữ toàn bộ hội thoại sau khi nhận phản hồi hoàn chỉnh
      _saveMessages();

    } catch (e) {
      print("❌ Lỗi Gemini API Stream: $e");
      messages[aiResponseIndex] = ChatMessageModel(
        text: "Hệ thống AI gặp sự cố nhỏ hoặc kết nối gián đoạn. Bạn vui lòng kiểm tra mạng và thử lại nhé! (Lỗi: $e)",
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.refresh();
      _saveMessages();
    } finally {
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  // 💡 Xóa sạch lịch sử trò chuyện
  void clearHistory() {
    if (messages.length <= 1) return;

    Get.defaultDialog(
      title: 'Xác nhận xóa',
      middleText: 'Bạn có chắc chắn muốn xóa toàn bộ lịch sử trò chuyện không?',
      textConfirm: 'Xóa sạch',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back(); // Đóng Dialog
        messages.clear();
        clearAttachment();
        _saveMessages();
        
        // Khởi tạo lại phiên chat mới với Gemini
        _initGemini();
        _setWelcomeMessage();
        _saveMessages();
      },
    );
  }

  // Hàm tự động cuộn xuống tin nhắn mới nhất
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
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