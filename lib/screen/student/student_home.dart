import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_class/screen/User%20Profile/user%20profile.dart';

import '../../Logic/controller/user/auth_controller.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.to(() => userprofile()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          final userData = authController.userData.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, ${userData['name'] ?? 'Student'}!",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text("You are logged in as a Student."),
              const SizedBox(height: 40),
              const Text("Your attendance and payment details will appear here."),
            ],
          );
        }),
      ),
    );
  }
}