import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/theme_controller.dart';
import 'user_services_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ThemeController
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      // Background color is handled by theme
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Theme Mode Toggle
            Obx(() => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    themeController.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Dark Mode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch(
                    value: themeController.isDarkMode,
                    onChanged: (value) {
                      themeController.toggleTheme();
                    },
                  ),
                ],
              ),
            )),

            const SizedBox(height: 20),

            // Service Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => UserServicesPage()),
                icon: const Icon(Icons.miscellaneous_services_rounded),
                label: const Text(
                  "Add Your Services",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}