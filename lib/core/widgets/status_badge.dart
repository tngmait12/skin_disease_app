import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String statusText;

  const StatusBadge({super.key, required this.statusText});

  @override
  Widget build(BuildContext context) {

    Color statusColor = Colors.grey.withOpacity(0.8);
    if (statusText.contains('Cực kỳ nguy hiểm')) {
      statusColor = Colors.red.withOpacity(0.9);
    } else if (statusText.contains('Nghiêm trọng')) {
      statusColor = Colors.deepOrange.withOpacity(0.9);
    } else if (statusText.contains('Cấp tính')) {
      statusColor = Colors.orange.withOpacity(0.9);
    } else if (statusText.contains('Mãn tính')) {
      statusColor = Colors.amber.shade700.withOpacity(0.9);
    } else if (statusText.contains('Nhiễm trùng')) {
      statusColor = Colors.purple.withOpacity(0.8);
    } else if (statusText.contains('Lành tính')) {
      statusColor = Colors.blue.withOpacity(0.8);
    } else if (statusText.contains('Da khỏe mạnh')) {
      statusColor = Colors.green.withOpacity(0.8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}