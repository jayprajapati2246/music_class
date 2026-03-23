import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../screen/admin/admin_dashboard.dart';

class AdminAuthController extends GetxController {
  // Admin password
  final String adminPassword = "jay@2246";

  // Main admin access function
  Future<void> handleAdminAccess(BuildContext context) async {
    _showPasswordDialog(context);
  }

  // Password dialog
  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xff6A5AE0)),
              Text(
                "Admin Verification ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                  fontSize: 19,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Please enter admin password to continue.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                passwordController.dispose();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.trim() == adminPassword) {
                  Navigator.pop(dialogContext);
                  passwordController.dispose();

                  Get.to(() => const AdminDashboardPage());
                } else {
                  Get.snackbar(
                    "Access Denied",
                    "Incorrect password",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6A5AE0),
                foregroundColor: Colors.white,
              ),
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }
}
