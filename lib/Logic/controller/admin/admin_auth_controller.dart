import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../screen/admin/admin_dashboard.dart';

class AdminAuthController extends GetxController {

  final String adminPassword = "jay7227";

  // Main admin access function
  void handleAdminAccess(BuildContext context) {
    // Removed password verification as per request
    Get.to(() => AdminDashboardPage());
  }

  // Keeping the dialog method for reference if needed later, but it's not called anymore
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
          title: Row(
            children: const [
              Icon(Icons.admin_panel_settings, color: Color(0xff6A5AE0)),
              SizedBox(width: 8),
              Text(
                "Admin Verification",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ],
          ),
          content: Column(
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.trim() == adminPassword) {
                  Navigator.pop(dialogContext);
                  Get.to(() => AdminDashboardPage());
                } else {
                  Get.snackbar(
                    "Access Denied",
                    "Incorrect password",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
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