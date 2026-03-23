import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Logic/controller/user/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthController authController = Get.find();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Obx(() => Column(
                children: [
                  const SizedBox(height: 50),
                  _buildGlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 25,
                    child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Create New Password",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Account found for ${authController.resetEmail.value}. Please set your new password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _buildGlassContainer(
                    padding: const EdgeInsets.all(25),
                    borderRadius: 35,
                    child: Column(
                      children: [
                        _buildModernField(
                          controller: passwordController,
                          hint: "New Password",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          toggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 20),
                        _buildModernField(
                          controller: confirmPasswordController,
                          hint: "Confirm Password",
                          icon: Icons.lock_reset_rounded,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          toggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        const SizedBox(height: 30),
                        _buildPrimaryButton(
                          text: "RESET PASSWORD",
                          isLoading: authController.isLoading.value,
                          onPressed: () {
                            String password = passwordController.text.trim();
                            String confirm = confirmPasswordController.text.trim();
                            if (password.isEmpty || password.length < 6) {
                              Get.snackbar("Error", "Password must be at least 6 characters",
                                  backgroundColor: Colors.orange, colorText: Colors.white);
                              return;
                            }
                            if (password != confirm) {
                              Get.snackbar("Error", "Passwords do not match",
                                  backgroundColor: Colors.red, colorText: Colors.white);
                              return;
                            }
                            authController.resetPasswordDirectly(password);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, required double borderRadius, required EdgeInsets padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: const Color(0xFF6A5AE0).withOpacity(0.8), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                  onPressed: toggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required bool isLoading, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFF92278F)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ),
    );
  }
}
