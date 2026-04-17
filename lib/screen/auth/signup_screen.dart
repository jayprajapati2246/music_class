import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../Logic/controller/user/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthController authController = Get.find();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
              ),
            ),
          ),
          // Decorative background circles
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.2,
            child: Container(
              height: size.height * 0.5,
              width: size.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assate/image/WhatsApp_Image_2026-03-03_at_10.43.28_PM-removebg-preview.png",
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Header
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Text(
                    "Fill in your details to get started",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  // Signup Form Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          controller: nameController,
                          label: "Full Name",
                          hint: "John Doe",
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 18),
                        _buildInputField(
                          controller: phoneController,
                          label: "Phone Number",
                          hint: "+91 00000 00000",
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*$')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildInputField(
                          controller: emailController,
                          label: "Email",
                          hint: "example@email.com",
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        _buildInputField(
                          controller: passwordController,
                          label: "Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 18),
                        _buildInputField(
                          controller: confirmPasswordController,
                          label: "Confirm Password",
                          hint: "••••••••",
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),

                        const SizedBox(height: 40),

                        Obx(() => GestureDetector(
                          onTap: authController.isLoading.value
                              ? null
                              : () {
                            if (passwordController.text != confirmPasswordController.text) {
                              Get.snackbar("Error", "Passwords do not match",
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  colorText: Colors.white);
                              return;
                            }

                            String phone = phoneController.text.trim();
                            if (!phone.startsWith('+') || phone.length < 11) {
                              Get.snackbar("Error", "Enter country code (+) followed by 10 digits",
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  colorText: Colors.white);
                              return;
                            }

                            authController.register(
                              nameController.text.trim(),
                              emailController.text.trim(),
                              passwordController.text.trim(),
                              "Student", // Default role
                              phone: phone,
                            );
                          },
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4776E6).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: authController.isLoading.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontWeight: FontWeight.w600,color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
              prefixIcon: Icon(icon, color: const Color(0xFF6A5AE0).withOpacity(0.7)),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onToggle,
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}