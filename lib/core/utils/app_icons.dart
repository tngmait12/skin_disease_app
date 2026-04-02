import 'package:flutter/material.dart';

IconData getIconFromName(String iconName) {
  switch (iconName) {
    case 'water_drop': return Icons.water_drop_outlined;
    case 'spa': return Icons.spa_outlined;
    case 'wb_sunny': return Icons.wb_sunny_outlined;
    case 'cleaning_services': return Icons.cleaning_services_outlined;
    case 'nightlight_round': return Icons.nightlight_round;
    case 'science': return Icons.science_outlined;
    case 'warning': return Icons.warning_amber_rounded;
    case 'do_not_touch': return Icons.do_not_touch;
    case 'shield': return Icons.shield_outlined;
    case 'local_hospital': return Icons.local_hospital;
    default: return Icons.check_circle_outline; // Icon mặc định nếu gõ sai tên
  }
}