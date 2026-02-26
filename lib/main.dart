import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:music_class/screen.dart';

import 'Logic/controller/student_controller.dart';
import 'firebase_options.dart';

Future<void> main ()
async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(StudentController());
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Musciclass(),
    ),
  );
}

class Musciclass extends StatefulWidget
{
  @override
  State<Musciclass> createState() => _StateMusicclass();

}

class _StateMusicclass extends State<Musciclass>
{
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Mainscreen(),
    );
  }
}