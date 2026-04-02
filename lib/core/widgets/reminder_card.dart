import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/reminder/reminder_controller.dart';

class ReminderCard extends StatelessWidget {
  final ReminderController reminderCtrl;
  final bool isMorning;

  const ReminderCard({
    super.key,
    required this.reminderCtrl,
    required this.isMorning,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOn = isMorning
          ? reminderCtrl.isMorningOn.value
          : reminderCtrl.isEveningOn.value;
      final time = isMorning
          ? reminderCtrl.morningTime.value
          : reminderCtrl.eveningTime.value;
      final timeString = time.format(context);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isOn
              ? Colors.teal.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isOn
                  ? Colors.teal.withOpacity(0.5)
                  : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.alarm, color: isOn ? Colors.teal : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhắc nhở bôi thuốc',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOn ? Colors.teal[800] : Colors.grey[700]),
                  ),
                  GestureDetector(
                    onTap: () => reminderCtrl.pickTime(context, isMorning),
                    child: Text(
                      'Lúc: $timeString (Nhấn đổi giờ)',
                      style: TextStyle(
                          color: isOn ? Colors.teal : Colors.grey,
                          decoration: TextDecoration.underline,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOn,
              activeColor: Colors.teal,
              onChanged: (value) {
                if (isMorning) {
                  reminderCtrl.toggleMorning(value);
                } else {
                  reminderCtrl.toggleEvening(value);
                }
              },
            ),
          ],
        ),
      );
    });
  }
}