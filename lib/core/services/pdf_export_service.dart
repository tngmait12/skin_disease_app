import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/scan_model.dart';
import '../models/routine_model.dart';
import '../../features/auth/controllers/profile_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';

class PdfExportService {

  // Hàm chính để tạo và hiển thị file PDF
  static Future<void> generateAndPreviewReport({
    required ScanModel scan,
    required SkinRoutine routine,
  }) async {
    final pdf = pw.Document();

    // Tự động nhúng font Roboto hỗ trợ Tiếng Việt
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    // Đọc hình ảnh lâm sàng cục bộ từ máy hoặc tải từ URL đám mây
    pw.ImageProvider? imageProvider;
    if (scan.localImagePath.isNotEmpty) {
      try {
        final imageFile = File(scan.localImagePath);
        if (imageFile.existsSync()) {
          final imageBytes = imageFile.readAsBytesSync();
          imageProvider = pw.MemoryImage(imageBytes);
        }
      } catch (e) {
        print('⚠️ Lỗi khi đọc hình ảnh cục bộ cho PDF: $e');
      }
    }

    // Nếu ảnh cục bộ không khả dụng, thử tải từ firebaseImageUrl trực tuyến
    if (imageProvider == null && scan.firebaseImageUrl.isNotEmpty) {
      try {
        imageProvider = await networkImage(scan.firebaseImageUrl);
      } catch (e) {
        print('⚠️ Lỗi khi tải hình ảnh từ đám mây (firebaseImageUrl) cho PDF: $e');
      }
    }

    // Lấy thông tin tài khoản và profile người dùng từ controllers
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final authController = Get.find<AuthController>();
    
    final profile = profileController.userProfile.value;
    final isGuest = authController.isGuest;

    final String fullName = isGuest ? 'Người dùng Khách' : (profile?.fullName != null && profile!.fullName.isNotEmpty ? profile.fullName : 'Thành viên SkinShield');
    final String email = isGuest ? 'Khách ẩn danh' : (profile?.email != null && profile!.email.isNotEmpty ? profile.email : authController.userEmail);
    final String phoneNumber = isGuest ? 'Chưa thiết lập' : (profile?.phoneNumber != null && profile!.phoneNumber.isNotEmpty ? profile.phoneNumber : 'Chưa thiết lập');
    final String dob = isGuest ? 'Chưa thiết lập' : (profile?.dob != null && profile!.dob.isNotEmpty ? _formatDobStr(profile.dob) : 'Chưa thiết lập');
    final String gender = isGuest ? 'Chưa thiết lập' : (profile?.gender ?? 'Chưa xác định');
    final String uid = authController.currentUserId.value;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5)),
            ),
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SkinShield Dermatological System - Báo cáo bảo mật bệnh án',
                  style: pw.TextStyle(font: fontItalic, fontSize: 7, color: PdfColors.black),
                ),
                pw.Text(
                  'Trang ${context.pageNumber} / ${context.pagesCount}',
                  style: pw.TextStyle(font: fontRegular, fontSize: 7, color: PdfColors.black),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // 1. HEADER CHÍNH THỨC (QUY CHUẨN Y KHOA)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BÁO CÁO PHÂN TÍCH BỆNH LÝ DA LIỄU',
                      style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'HỆ THỐNG PHÂN TÍCH VÀ QUẢN LÝ SỨC KHỎE DA LIỄU SKINSHIELD',
                      style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: PdfColors.black),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'MÃ BỆNH ÁN: #REP-${scan.id.toUpperCase().substring(0, min(8, scan.id.length))}',
                      style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Ngày chẩn đoán: ${DateFormat('dd/MM/yyyy HH:mm').format(scan.date)}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: PdfColors.black),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            // Đường kẻ đôi cổ điển
            pw.Container(
              height: 3,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black, width: 1.2),
                  top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                ),
              ),
            ),
            pw.SizedBox(height: 12),

            // 2. THÔNG TIN NGƯỜI DÙNG (USER PROFILE)
            pw.Text(
              'I. THÔNG TIN BỆNH NHÂN (USER PROFILE)',
              style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              children: [
                pw.TableRow(
                  children: [
                    _buildTableCell('Họ và tên:', fullName, fontBold),
                    _buildTableCell('Ngày sinh:', dob, fontBold),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Số điện thoại:', phoneNumber, fontBold),
                    _buildTableCell('Giới tính:', gender, fontBold),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Email liên hệ:', email, fontBold),
                    _buildTableCell('Mã người dùng (UID):', uid, fontBold),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // 3. KẾT QUẢ CHẨN ĐOÁN LÂM SÀNG & HÌNH ẢNH
            pw.Text(
              'II. KẾT QUẢ CHẨN ĐOÁN LÂM SÀNG & HÌNH ẢNH',
              style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cột trái: Thông tin chẩn đoán
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5),
                      color: PdfColors.grey100,
                    ),
                    height: 135,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'KẾT LUẬN CỦA AI:',
                          style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black),
                        ),
                        pw.Text(
                          scan.diseaseName.toUpperCase(),
                          style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.black),
                        ),
                        pw.Divider(thickness: 0.5, color: PdfColors.black),
                        pw.RichText(
                          text: pw.TextSpan(
                            text: 'Độ tin cậy xác thực: ',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
                            children: [
                              pw.TextSpan(
                                text: '${scan.confidence.toStringAsFixed(1)}%',
                                style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black),
                              ),
                            ],
                          ),
                        ),
                        pw.RichText(
                          text: pw.TextSpan(
                            text: 'Hình thức kiểm tra: ',
                            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.black),
                            children: [
                              pw.TextSpan(
                                text: 'Ảnh chụp phân tích AI',
                                style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 15),
                // Cột phải: Hình ảnh lâm sàng đính kèm
                pw.Column(
                  children: [
                    pw.Container(
                      width: 120,
                      height: 120,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 0.5),
                      ),
                      padding: const pw.EdgeInsets.all(2),
                      child: imageProvider != null
                          ? pw.Image(imageProvider, fit: pw.BoxFit.cover)
                          : pw.Center(
                              child: pw.Text(
                                'Hình ảnh lâm sàng\n(Không khả dụng)',
                                style: pw.TextStyle(font: fontItalic, fontSize: 7, color: PdfColors.black),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Hình 1: Vùng da tổn thương',
                      style: pw.TextStyle(font: fontItalic, fontSize: 7, color: PdfColors.black),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // 4. PHÁC ĐỒ CHĂM SÓC & HƯỚNG DẪN HẰNG NGÀY
            pw.Text(
              'III. PHÁC ĐỒ CHĂM SÓC & HƯỚNG DẪN HẰNG NGÀY',
              style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.black),
            ),
            pw.SizedBox(height: 5),
            
            // Khung Cảnh báo Y tế (Nếu có)
            if (routine.medicalAlert.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1.2),
                  color: PdfColors.grey100,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '[!] CẢNH BÁO Y TẾ QUAN TRỌNG:',
                      style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      routine.medicalAlert,
                      style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.black),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
            ],

            // Bảng Routine Sáng - Tối
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(3),
              },
              children: [
                // Header Bảng
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('THỜI GIAN', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black), textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('CHI TIẾT PHÁC ĐỒ THEO DÕI & CHĂM SÓC DA', style: pw.TextStyle(font: fontBold, fontSize: 8.5, color: PdfColors.black), textAlign: pw.TextAlign.center),
                    ),
                  ],
                ),
                // Buổi sáng
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('SÁNG\n(Morning)', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black), textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: routine.morningRoutine.isEmpty
                            ? [pw.Text('Không có chỉ định đặc biệt cho buổi sáng.', style: pw.TextStyle(fontSize: 8, color: PdfColors.black))]
                            : routine.morningRoutine.map((step) {
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 3),
                                  child: pw.RichText(
                                    text: pw.TextSpan(
                                      text: '- ${step.title}: ',
                                      style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black),
                                      children: [
                                        pw.TextSpan(
                                          text: step.description,
                                          style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ],
                ),
                // Buổi tối
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('TỐI\n(Evening)', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black), textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: routine.eveningRoutine.isEmpty
                            ? [pw.Text('Không có chỉ định đặc biệt cho buổi tối.', style: pw.TextStyle(fontSize: 8, color: PdfColors.black))]
                            : routine.eveningRoutine.map((step) {
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 3),
                                  child: pw.RichText(
                                    text: pw.TextSpan(
                                      text: '- ${step.title}: ',
                                      style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black),
                                      children: [
                                        pw.TextSpan(
                                          text: step.description,
                                          style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),

            // 5. HOẠT CHẤT ĐỀ XUẤT VÀ THÀNH PHẦN CẦN TRÁNH
            if (routine.recommendIngredients.isNotEmpty || routine.avoidIngredients.isNotEmpty) ...[
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (routine.recommendIngredients.isNotEmpty)
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 0.5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('[+] Hoạt chất khuyên dùng:', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black)),
                            pw.SizedBox(height: 4),
                            ...routine.recommendIngredients.map((ing) => pw.Text('- $ing', style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: PdfColors.black))),
                          ],
                        ),
                      ),
                    ),
                  if (routine.recommendIngredients.isNotEmpty && routine.avoidIngredients.isNotEmpty)
                    pw.SizedBox(width: 10),
                  if (routine.avoidIngredients.isNotEmpty)
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 0.5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('[-] Thành phần cần tránh:', style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black)),
                            pw.SizedBox(height: 4),
                            ...routine.avoidIngredients.map((ing) => pw.Text('- $ing', style: pw.TextStyle(font: fontRegular, fontSize: 7.5, color: PdfColors.black))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              pw.SizedBox(height: 15),
            ],

            // 6. CHÂN TRANG - KHUYÊN CÁO PHÁP LÝ CHÍNH THỨC
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 10),
              padding: const pw.EdgeInsets.only(top: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.black, width: 0.5)),
              ),
              child: pw.Center(
                child: pw.Text(
                  'LƯU Ý Y KHOA QUAN TRỌNG: Báo cáo phân tích da liễu này được tự động thiết lập bởi hệ thống Trí tuệ Nhân tạo (AI) dựa trên các thuật toán phân tích hình ảnh lâm sàng.\nKết quả này chỉ có tính chất tham khảo khoa học bước đầu và tuyệt đối không thể thay thế cho các chẩn đoán, sinh thiết chuyên khoa từ các Bác sĩ có chuyên môn da liễu.',
                  style: pw.TextStyle(font: fontItalic, fontSize: 6.5, color: PdfColors.black),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          ];
        },
      ),
    );

    // Mở màn hình Preview PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bao_Cao_Da_Lieu_${scan.id}.pdf',
    );
  }

  // Helper vẽ các ô dữ liệu trong bảng hồ sơ bệnh nhân
  static pw.Widget _buildTableCell(String label, String value, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.RichText(
        text: pw.TextSpan(
          text: '$label ',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
          children: [
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Format ngày sinh định dạng yyyy-MM-dd thành dd/MM/yyyy
  static String _formatDobStr(String dob) {
    if (dob.isEmpty) return 'Chưa thiết lập';
    try {
      final parts = dob.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (_) {}
    return dob;
  }

  // Helper để lấy hàm min không cần math import
  static int min(int a, int b) => a < b ? a : b;
}