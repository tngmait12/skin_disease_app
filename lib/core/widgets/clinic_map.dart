import 'package:flutter/material.dart';

import '../services/clinic_map_service.dart';

class ClinicMap extends StatelessWidget {

  final Color backgroundColor;

  const ClinicMap({
    super.key,
    this.backgroundColor = Colors.blue,
  });



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ClinicMapService.findNearbyClinics();
        },
        icon: const Icon(Icons.location_on_rounded, color: Colors.white),
        label: const Text('Tìm phòng khám Da liễu gần nhất', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor, // Màu đỏ báo động
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }
}