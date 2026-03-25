import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:music_class/screen/setting.dart';
import '../Logic/controller/admin/admin_auth_controller.dart';
import '../Logic/controller/user/auth_controller.dart';

class userprofile extends StatefulWidget {
  const userprofile({super.key});

  @override
  State<userprofile> createState() => _userprofileState();
}

class _userprofileState extends State<userprofile> {
  final AuthController authController = Get.find();
  final AdminAuthController adminAuthController = Get.put(
    AdminAuthController(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(() {
        var userData = authController.userData.value;
        if (userData.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: theme.primaryColor),
          );
        }

        String profileImg = userData['profileImage'] ?? '';
        String name = userData['name'] ?? 'Not Available';
        String email = userData['email'] ?? 'Not Available';
        String phone = userData['phone'] ?? 'Not Available';
        String role = userData['role'] ?? 'Student';

        String joinedDate = "Joined Recently";
        if (userData['createdAt'] != null) {
          try {
            var dt = userData['createdAt'].toDate();
            joinedDate = "Joined on " + DateFormat('MMM dd, yyyy').format(dt);
          } catch (e) {
            joinedDate = "Joined Recently";
          }
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF1A1A2E),
                                const Color(0xFF16213E),
                                const Color(0xFF0F3460),
                              ]
                            : [
                                const Color(0xff6A5AE0),
                                const Color(0xff8E54E9),
                                const Color(0xff92278F),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Positioned(
                    top: 60,
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -50,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? theme.cardColor : Colors.white,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: isDark
                            ? theme.cardColor
                            : Colors.white,
                        backgroundImage: profileImg.isNotEmpty
                            ? NetworkImage(profileImg)
                            : null,
                        child: profileImg.isEmpty
                            ? Icon(
                                Icons.person_rounded,
                                size: 85,
                                color: theme.primaryColor,
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 70),

              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                joinedDate,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // --- ROLE BASED ADMIN PANEL ---
              if (role == "Admin") ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildAdminDashboardSection(context),
                ),
                const SizedBox(height: 20),
              ],

              // --- PERSONAL INFO CARD ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      context,
                      Icons.person_outline,
                      "Full Name",
                      name,
                    ),
                    Divider(
                      height: 30,
                      thickness: 0.6,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    _buildInfoRow(
                      context,
                      Icons.email_outlined,
                      "Email",
                      email,
                    ),
                    Divider(
                      height: 30,
                      thickness: 0.6,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    _buildInfoRow(
                      context,
                      Icons.phone_iphone_rounded,
                      "Phone",
                      phone,
                    ),
                    Divider(
                      height: 30,
                      thickness: 0.6,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const SettingsPage());
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_rounded,
                              color: theme.primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                "App Settings",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: isDark ? Colors.white24 : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "Sign Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDark
                              ? Colors.red.withOpacity(0.2)
                              : Colors.red.shade100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAdminDashboardSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F3460), const Color(0xFF16213E)]
              : [const Color(0xFF6A5AE0), const Color(0xFF4776E6)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.admin_panel_settings, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Admin Controls",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Access powerful tools to manage users, view all records, and edit/delete system data.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                adminAuthController.handleAdminAccess(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isDark
                    ? const Color(0xFF1A1A2E)
                    : const Color(0xFF6A5AE0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "OPEN ADMIN PANEL",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Sign Out",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          "Are you sure you want to exit?",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
