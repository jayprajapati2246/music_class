import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Logic/controller/user/auth_controller.dart';
import 'Logic/controller/user/student_controller.dart';
import 'firebase_options.dart';
import 'screen/auth/splash_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await MobileAds.instance.initialize();
  
  // Initialize Controllers
  Get.put(AuthController());
  Get.put(StudentController());

  runApp(const MusicClassApp());
}

class MusicClassApp extends StatelessWidget {
  const MusicClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MelodyMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
