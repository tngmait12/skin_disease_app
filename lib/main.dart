import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/utils/tflite_helper.dart';
import 'features/home/views/home_view.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await TFLiteHelper.loadModel();
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
      home: HomeView(),
    );
  }
}