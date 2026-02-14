import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skin Disease Predictor',
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG xấu xí ở góc
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Dự án Đồ án Tốt nghiệp - Đã sẵn sàng!'),
        ),
      ),
    );
  }
}