import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Logic/controller/auth_controller.dart';

class userprofile extends StatefulWidget {
  const userprofile({super.key});

  @override
  State<userprofile> createState() => _userprofileState();
}

class _userprofileState extends State<userprofile> {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FE),
      body: Obx(() {
        var userData = authController.userData.value;
        if (userData.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xff6A5AE0)));
        }

        String profileImg = userData['profileImage'] ?? '';
        String name = userData['name'] ?? 'Not Available';
        String email = userData['email'] ?? 'Not Available';
        String phone = userData['phone'] ?? 'Not Available';
        
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
              // --- ATTRACTIVE TOP SECTION ---
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Gradient Background Header
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff6A5AE0), Color(0xff8E54E9), Color(0xff92278F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Profile Title in Header
                  const Positioned(
                    top: 60,
                    child: Text(
                      "User Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Floating Profile Image
                  Positioned(
                    bottom: -50,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff6A5AE0).withOpacity(0.3),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImg.isNotEmpty ? NetworkImage(profileImg) : null,
                        child: profileImg.isEmpty
                            ? const Icon(Icons.person_rounded, size: 85, color: Color(0xff6A5AE0))
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 70),
              
              // Name
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF1A1D1E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Joined Date Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff6A5AE0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  joinedDate,
                  style: const TextStyle(
                    fontSize: 13, 
                    color: Color(0xff6A5AE0), 
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
              
              const SizedBox(height: 40),

              // Main Information Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Personal Information",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    _buildInfoRow(Icons.person_outline_rounded, "Full Name", name),
                    const Divider(height: 35, thickness: 0.6, color: Color(0xffF1F1F1)),
                    _buildInfoRow(Icons.phone_iphone_rounded, "Phone Number", phone),
                    const Divider(height: 35, thickness: 0.6, color: Color(0xffF1F1F1)),
                    _buildInfoRow(Icons.email_outlined, "Email ID", email),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, size: 22),
                    label: const Text(
                      "Logout Account",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFFF0F0),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      side: const BorderSide(color: Color(0xffFFD6D6), width: 1.5),
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

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xff6A5AE0).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xff6A5AE0), size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1D1E)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Logout Confirmation", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit your account?"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
