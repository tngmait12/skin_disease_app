import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_disease_app/features/onboarding/screens/onboarding_screen.dart';
import 'core/utils/tflite_helper.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/main/screens/main_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  await TFLiteHelper.loadModel();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AuthController());
  runApp(const SkinDiseaseApp());
}

class SkinDiseaseApp extends StatelessWidget {
  const SkinDiseaseApp({super.key});
  // AIzaSyBhxX_Z0FQwQPGmGPbVfeeV9GBlD4J4vGQ
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skin Disease Predictor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: GetStorage().read('isFirstTime') == false ? const MainScreen() : const OnboardingScreen(),
    );
  }
}