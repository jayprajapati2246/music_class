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
