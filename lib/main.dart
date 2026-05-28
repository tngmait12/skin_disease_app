import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/tflite_helper.dart';
import 'core/utils/routine_generator.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

late List<CameraDescription> cameras;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  await TFLiteHelper.loadModel();
  await RoutineGenerator.initialize();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(AuthController());
  Get.put(LocalStorageService());
  await Get.putAsync(() => NotificationService().init());
  runApp(const SkinDiseaseApp());
}

class SkinDiseaseApp extends StatelessWidget {
  const SkinDiseaseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Skin Shield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
      initialRoute: Routes.INITIAL,
      getPages: AppPages.routes,
    );
  }
}