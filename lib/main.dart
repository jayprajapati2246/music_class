import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Logic/controller/theme_controller.dart';
import 'Logic/controller/user/auth_controller.dart';
import 'Logic/controller/user/student_controller.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'firebase_options.dart';
import 'screen/auth/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Ads
  await MobileAds.instance.initialize();
  
  // Initialize Controllers permanently
  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(StudentController(), permanent: true);

  runApp(const MusicClassApp());
}

class MusicClassApp extends StatelessWidget {
  const MusicClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use put here as a fail-safe to ensure the instance is available for the Obx
    final themeController = Get.put(ThemeController(), permanent: true);
    
    return Obx(() => GetMaterialApp(
      title: 'MelodyMaster',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.theme,
      
      home: const SplashScreen(),
    ));
  }
}

// Global function for attractive snackbar
void showAttractiveSnackbar(String title, String message, {bool isError = false}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red.withOpacity(0.9) : const Color(0xff6A5AE0).withOpacity(0.9),
    colorText: Colors.white,
    margin: const EdgeInsets.all(15),
    borderRadius: 15,
    icon: Icon(
      isError ? Icons.error_outline : Icons.check_circle_outline,
      color: Colors.white,
    ),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
