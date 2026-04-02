import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Đảm bảo import đúng đường dẫn model của bạn
import '../models/scan_model.dart';
import '../models/routine_model.dart';

class PdfExportService {

  // Hàm chính để tạo và hiển thị file PDF
  static Future<void> generateAndPreviewReport({
    required ScanModel scan,
    required SkinRoutine routine,
  }) async {
    final pdf = pw.Document();

    // 💡 GIẢI PHÁP TIẾNG VIỆT: Tự động nhúng font Roboto từ Google Fonts
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(fontBold),
            pw.SizedBox(height: 20),
            _buildPatientInfo(scan, fontBold),
            pw.SizedBox(height: 20),

            // Nếu có cảnh báo y tế (ví dụ: Ung thư), hiển thị khung đỏ
            if (routine.medicalAlert.isNotEmpty) ...[
              _buildMedicalAlert(routine.medicalAlert, fontBold),
              pw.SizedBox(height: 20),
            ],

            _buildRoutineTable(routine, fontBold),
            pw.SizedBox(height: 40),
            _buildFooter(fontItalic),
          ];
        },
      ),
    );

    // 💡 Lệnh này sẽ mở ra một màn hình Preview cực xịn, có sẵn nút Print và Share (Zalo, Email...)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bao_Cao_Da_Lieu_${scan.id}.pdf',
    );
  }

  // ==========================================
  // CÁC KHỐI GIAO DIỆN (WIDGETS) CỦA PDF
  // ==========================================

  // 1. Tiêu đề
  static pw.Widget _buildHeader(pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'BÁO CÁO PHÂN TÍCH DA LIỄU AI',
          style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.teal800),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Được tạo bởi Ứng dụng Skin Health',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 2, color: PdfColors.teal200),
      ],
    );
  }

  // 2. Thông tin kết quả quét
  static pw.Widget _buildPatientInfo(ScanModel scan, pw.Font fontBold) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(scan.date);
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('THÔNG TIN CHẨN ĐOÁN', style: pw.TextStyle(font: fontBold, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Thời gian quét: $dateStr'),
              pw.Text('Độ tin cậy AI: ${scan.confidence}%'),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.RichText(
            text: pw.TextSpan(
              text: 'Kết luận AI: ',
              children: [
                pw.TextSpan(
                  text: scan.diseaseName,
                  style: pw.TextStyle(font: fontBold, color: PdfColors.red800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Khung cảnh báo (Dành cho bệnh nặng)
  static pw.Widget _buildMedicalAlert(String alertMessage, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        border: pw.Border.all(color: PdfColors.red),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              alertMessage,
              style: pw.TextStyle(font: fontBold, color: PdfColors.red800),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Bảng Phác đồ
  // 4. Bảng Phác đồ (Đã sửa lỗi textAlign)
  static pw.Widget _buildRoutineTable(SkinRoutine routine, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('PHÁC ĐỒ CHĂM SÓC ĐỀ XUẤT', style: pw.TextStyle(font: fontBold, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header Bảng
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.teal100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  // 💡 SỬA: Đưa textAlign ra ngoài TextStyle
                  child: pw.Text('BUỔI', style: pw.TextStyle(font: fontBold), textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('CÁC BƯỚC THỰC HIỆN', style: pw.TextStyle(font: fontBold), textAlign: pw.TextAlign.center),
                ),
              ],
            ),
            // Hàng: Buổi sáng
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  // 💡 SỬA: Đưa textAlign ra ngoài TextStyle
                  child: pw.Text('SÁNG', style: pw.TextStyle(font: fontBold, color: PdfColors.orange700), textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: routine.morningRoutine.map((step) => pw.Text('- ${step.title}: ${step.description}')).toList(),
                  ),
                ),
              ],
            ),
            // Hàng: Buổi tối
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  // 💡 SỬA: Đưa textAlign ra ngoài TextStyle
                  child: pw.Text('TỐI', style: pw.TextStyle(font: fontBold, color: PdfColors.indigo700), textAlign: pw.TextAlign.center),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: routine.eveningRoutine.map((step) => pw.Text('- ${step.title}: ${step.description}')).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 5. Chân trang (Disclaimer)
  static pw.Widget _buildFooter(pw.Font fontItalic) {
    return pw.Center(
      child: pw.Text(
        '* Lưu ý: Báo cáo này được tạo tự động bởi Trí tuệ Nhân tạo và chỉ mang tính chất tham khảo.\nVui lòng thăm khám bác sĩ Da liễu để có phác đồ điều trị chính xác nhất.',
        style: pw.TextStyle(font: fontItalic, fontSize: 10, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}