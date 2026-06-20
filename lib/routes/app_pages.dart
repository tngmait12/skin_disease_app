import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/models/scan_model.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/main/screens/main_screen.dart';
import '../features/camera/screens/custom_camera_screen.dart';
import '../features/camera/screens/review_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/history/screens/history_detail_screen.dart';
import '../features/routine/screens/routine_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/splash/screens/splash_screen.dart';

import '../features/main/controllers/main_controller.dart';
import '../features/home/controllers/home_controller.dart';
import '../features/history/controllers/history_controller.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/chat/controllers/chat_controller.dart';
import '../features/auth/controllers/profile_controller.dart';
import '../features/camera/controllers/custom_camera_controller.dart';
import '../features/splash/controllers/splash_controller.dart';

import 'app_routes.dart';

class OnboardingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final isFirstTime = GetStorage().read('isFirstTime') ?? true;
    if (isFirstTime) {
      return const RouteSettings(name: Routes.ONBOARDING);
    }
    return null;
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

class AppPages {
  static final routes = [
    // Initial Route - will load the premium animated SplashScreen
    GetPage(
      name: Routes.INITIAL,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SplashController());
      }),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => MainScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MainController());
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => HistoryController());
        Get.lazyPut(() => DashboardController());
        Get.lazyPut(() => ChatController());
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.CAMERA,
      page: () => CustomCameraScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CustomCameraController());
      }),
    ),
    GetPage(
      name: Routes.REVIEW,
      page: () => ReviewScreen(imagePath: Get.arguments as String),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => HistoryScreen(),
    ),
    GetPage(
      name: Routes.HISTORY_DETAIL,
      page: () => HistoryDetailScreen(item: Get.arguments as ScanModel),
    ),
    GetPage(
      name: Routes.ROUTINE,
      page: () => RoutineScreen(diseaseName: (Get.arguments as String?) ?? 'Da khỏe mạnh (Heathy)'),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreen(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => ChatScreen(),
    ),
  ];
}
