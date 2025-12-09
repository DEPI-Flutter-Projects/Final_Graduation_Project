import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';
import '../../data/services/theme_service.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildGlassForm(context),
                  const SizedBox(height: 30),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildSocialButtons(),
                  const SizedBox(height: 30),
                  _buildFooterToggle(),
                ],
              ),
            ),
          ),
          _buildThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final isDark = ThemeService.to.isDarkMode;
            return IconButton(
              onPressed: () => ThemeService.to.switchTheme(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(Get.context!).cardColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(Get.context!)
                        .dividerColor
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.orange : Colors.white,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Obx(() {
      final isDark = ThemeService.to.isDarkMode;
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A237E),
                    const Color(0xFF0D47A1),
                    const Color(0xFF01579B),
                    const Color(0xFF006064),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                    const Color(0xFF90CAF9),
                    const Color(0xFF64B5F6),
                  ],
          ),
        ),
      )
          .animate(
              key: ValueKey(isDark),
              onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
              duration: const Duration(seconds: 5),
              color: isDark ? Colors.white10 : Colors.white54);
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Obx(() {
      final isDark = ThemeService.to.isDarkMode;
      final textColor = isDark ? Colors.white : Colors.black87;
      final subTextColor = isDark ? Colors.white70 : Colors.black54;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white24
                    : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 60,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text(
            controller.isLoginMode.value ? 'Welcome Back!' : 'Create Account',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
              shadows: isDark
                  ? [
                      const Shadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
          ).animate().fadeIn().moveY(begin: 20, end: 0),
          const SizedBox(height: 8),
          Text(
            controller.isLoginMode.value
                ? 'Login to continue your journey'
                : 'Join us and start your trip',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: subTextColor,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      );
    });
  }

  Widget _buildGlassForm(BuildContext context) {
    return Obx(() {
      final isDark = ThemeService.to.isDarkMode;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              if (!controller.isLoginMode.value)
                _buildTextField(
                  controller: controller.nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  isDark: isDark,
                )
                    .animate(target: controller.shakeTrigger.value > 0 ? 1 : 0)
                    .shake(
                        hz: 8, curve: Curves.easeInOutCubic, duration: 500.ms)
                    .animate()
                    .fadeIn()
                    .scaleY(begin: 0, end: 1, alignment: Alignment.topCenter),
              if (!controller.isLoginMode.value) const SizedBox(height: 16),
              _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                validator: (v) =>
                    !GetUtils.isEmail(v!) ? 'Invalid Email' : null,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              )
                  .animate(target: controller.shakeTrigger.value > 0 ? 1 : 0)
                  .shake(hz: 8, curve: Curves.easeInOutCubic, duration: 500.ms),
              const SizedBox(height: 16),
              Obx(() => _buildTextField(
                        controller: controller.passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: !controller.isPasswordVisible.value,
                        isDark: isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                      ))
                  .animate(target: controller.shakeTrigger.value > 0 ? 1 : 0)
                  .shake(hz: 8, curve: Curves.easeInOutCubic, duration: 500.ms),
              const SizedBox(height: 12),
              if (controller.isLoginMode.value)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.forgotPassword),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          controller.isLoginMode.value ? 'LOGIN' : 'SIGN UP',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white70 : Colors.black54;
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.1);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.2);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(icon, color: hintColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
      ),
    );
  }

  Widget _buildDivider() {
    return Obx(() {
      final isDark = ThemeService.to.isDarkMode;
      final color = isDark ? Colors.white24 : Colors.black12;
      final textColor = isDark ? Colors.white54 : Colors.black45;

      return Row(
        children: [
          Expanded(child: Divider(color: color)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR CONTINUE WITH',
              style: GoogleFonts.outfit(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: color)),
        ],
      );
    });
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: controller.signInWithGoogle,
            icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
            label: Text(
              'Continue with Google',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildFooterToggle() {
    return Obx(() {
      final isDark = ThemeService.to.isDarkMode;
      final textColor = isDark ? Colors.white70 : Colors.black54;

      return TextButton(
        onPressed: controller.toggleMode,
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.outfit(color: textColor, fontSize: 16),
            children: [
              TextSpan(
                text: controller.isLoginMode.value
                    ? "Don't have an account? "
                    : "Already have an account? ",
              ),
              TextSpan(
                text: controller.isLoginMode.value ? "Sign Up" : "Login",
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
