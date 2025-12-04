import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/app_snackbars.dart';
import '../profile/profile_controller.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoginMode = true.obs;
  final RxBool isPasswordVisible = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  final RxInt shakeTrigger = 0.obs;
  String? _lastAttemptedEmail;
  String? _lastAttemptedPassword;

  
  final RxInt resetCooldown = 0.obs;
  Timer? _cooldownTimer;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      shakeTrigger.value++; 
      return;
    }

    if (isLoading.value) return; 

    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();

    
    if (_lastAttemptedEmail == email && _lastAttemptedPassword == password) {
      shakeTrigger.value++; 
      return;
    }

    isLoading.value = true;
    try {
      if (isLoginMode.value) {
        
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.session == null) {
          _handleAuthError('Login failed. Please check your credentials.');
          return;
        }
      } else {
        
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );

        
        if (response.session == null && response.user != null) {
          AppSnackbars.showInfo(
            'Success',
            'Account created! Please check your email to confirm your account before logging in.',
          );
          isLoginMode.value = true; 
          return; 
        }
      }

      
      _lastAttemptedEmail = null;
      _lastAttemptedPassword = null;

      
      if (Get.isRegistered<ProfileController>()) {
        await ProfileController.to.loadUserProfile();
      }

      Get.offAllNamed(Routes.MAIN);
      AppSnackbars.showSuccess(
        'Success',
        isLoginMode.value ? 'Welcome back!' : 'Account created successfully!',
      );
    } on AuthException catch (e) {
      
      debugPrint('Auth error: ${e.message}, Status: ${e.statusCode}');

      String errorMessage = e.message;

      
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('credentials')) {
        errorMessage =
            'Invalid email or password. Please check your credentials and try again.';
      } else if (e.message.toLowerCase().contains('not found')) {
        errorMessage =
            'No account found with this email. Please sign up first.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage = 'Please confirm your email address before logging in.';
      }

      _handleAuthError(errorMessage);
    } catch (e) {
      debugPrint('Unexpected error during auth: $e');
      _handleAuthError('An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(String message) {
    shakeTrigger.value++;
    _lastAttemptedEmail = emailController.text.trim();
    _lastAttemptedPassword = passwordController.text;
    AppSnackbars.showError('Authentication Error', message);
  }

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        Get.toNamed(Routes.RESET_PASSWORD);
      } else if (event == AuthChangeEvent.signedIn) {
        if (Get.isRegistered<ProfileController>()) {
          ProfileController.to.loadUserProfile();
        }
      }
    });
  }

  Future<void> sendPasswordResetEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      AppSnackbars.showError('Error', 'Please enter your email address');
      return;
    }

    if (resetCooldown.value > 0) {
      AppSnackbars.showInfo(
        'Please Wait',
        'You can send another reset email in ${resetCooldown.value} seconds.',
      );
      return;
    }

    isLoading.value = true;
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.elmoshwar://login-callback',
      );
      AppSnackbars.showSuccess(
        'Email Sent',
        'Check your email for the password reset link.',
      );
      startCooldown(60); 
      Get.back(); 
    } on AuthException catch (e) {
      if (e.statusCode == '429' ||
          e.message.toLowerCase().contains('rate limit') ||
          e.code == 'over_email_send_rate_limit') {
        startCooldown(60); 
        AppSnackbars.showError(
          'Too Many Attempts',
          'Please wait a minute before requesting another reset link.',
        );
      } else {
        AppSnackbars.showError(
            'Error', 'Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to send reset email: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startCooldown(int seconds) {
    resetCooldown.value = seconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resetCooldown.value > 0) {
        resetCooldown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resetPassword(String newPassword) async {
    isLoading.value = true;
    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        AppSnackbars.showSuccess(
          'Success',
          'Password updated successfully! Please login with your new password.',
        );
        Get.offAllNamed(Routes.AUTH);
      }
    } catch (e) {
      AppSnackbars.showError('Error', 'Failed to reset password: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.elmoshwar://login-callback',
      );
      
      
    } catch (e) {
      AppSnackbars.showError('Error', 'Google Sign-In failed: $e');
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    isLoading.value = true;
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.elmoshwar://login-callback',
      );
    } catch (e) {
      AppSnackbars.showError('Error', 'Facebook Sign-In failed: $e');
      isLoading.value = false;
    }
  }

  void logout() async {
    await Supabase.instance.client.auth.signOut();
    if (Get.isRegistered<ProfileController>()) {
      ProfileController.to.clearProfile();
    }
    Get.offAllNamed(Routes.AUTH);
  }

  @override
  void onClose() {
    _cooldownTimer?.cancel();
    super.onClose();
  }
}
