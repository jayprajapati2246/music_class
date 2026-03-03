import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Logic/controller/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final AuthController authController = Get.find();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          // Animated Glow Orbs
          Positioned(
            top: size.height * 0.1,
            right: -size.width * 0.2,
            child: _buildGlowOrb(size.width * 0.7, const Color(0xFF6A5AE0).withOpacity(0.3)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Glassmorphic Icon Container
                    _buildGlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 25,
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Enter your email address to receive a password reset link.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Glassmorphic Input Card
                    _buildGlassContainer(
                      padding: const EdgeInsets.all(25),
                      borderRadius: 35,
                      child: Column(
                        children: [
                          _buildModernField(
                            controller: emailController,
                            hint: "Email Address",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 30),
                          Obx(() => _buildPrimaryButton(
                            text: "SEND RESET LINK",
                            isLoading: authController.isLoading.value,
                            onPressed: () {
                              if (emailController.text.isNotEmpty) {
                                authController.forgotPassword(emailController.text.trim());
                              } else {
                                Get.snackbar(
                                  "Error",
                                  "Please enter your email address",
                                  backgroundColor: Colors.red.withOpacity(0.8),
                                  colorText: Colors.white,
                                );
                              }
                            },
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Remembered your password?",
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 20,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: const Color(0xFF6A5AE0).withOpacity(0.8), size: 22),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF92278F)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A5AE0).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
        ),
      ),
    );
  }
}
