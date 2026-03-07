import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:skin_disease_app/features/onboarding/screens/onboarding_screen.dart';
import 'core/utils/tflite_helper.dart';
import 'features/main/screens/main_screen.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await TFLiteHelper.loadModel();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
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