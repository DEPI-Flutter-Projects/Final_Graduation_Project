import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../settings_controller.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    
    final shakeCurrent = 0.obs;
    final shakeNew = 0.obs;

    
    ever(controller.currentPasswordError, (error) {
      if (error.isNotEmpty) shakeCurrent.value++;
    });
    ever(controller.newPasswordError, (error) {
      if (error.isNotEmpty) shakeNew.value++;
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimaryLight, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 32),

            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secure your account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a strong password to keep your account safe.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    
                    Obx(() => _buildPasswordField(
                          controller: currentPasswordController,
                          label: 'Current Password',
                          isVisible: controller.isCurrentPasswordVisible,
                          errorText:
                              controller.currentPasswordError.value.isEmpty
                                  ? null
                                  : controller.currentPasswordError.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        )
                            .animate(target: shakeCurrent.value > 0 ? 1 : 0)
                            .shake(
                                duration: 400.ms,
                                hz: 4,
                                curve: Curves.easeInOutCubic)
                            .callback(callback: (_) => shakeCurrent.value = 0)),

                    const SizedBox(height: 20),

                    
                    Obx(() => _buildPasswordField(
                          controller: newPasswordController,
                          label: 'New Password',
                          isVisible: controller.isNewPasswordVisible,
                          errorText: controller.newPasswordError.value.isEmpty
                              ? null
                              : controller.newPasswordError.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 6) {
                              return 'Min 6 characters';
                            }
                            return null;
                          },
                        )
                            .animate(target: shakeNew.value > 0 ? 1 : 0)
                            .shake(
                                duration: 400.ms,
                                hz: 4,
                                curve: Curves.easeInOutCubic)
                            .callback(callback: (_) => shakeNew.value = 0)),

                    const SizedBox(height: 20),

                    
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      isVisible: controller.isConfirmPasswordVisible,
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      controller.updatePassword(
                                        currentPasswordController.text,
                                        newPasswordController.text,
                                      );
                                    } else {
                                      
                                      
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Update Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required RxBool isVisible,
    required String? Function(String?) validator,
    String? errorText,
  }) {
    return Obx(() => TextFormField(
          controller: controller,
          obscureText: !isVisible.value,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
            errorText: errorText,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible.value
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppColors.textSecondaryLight,
              ),
              onPressed: () => isVisible.toggle(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ));
  }
}

class SuccessDialog extends StatefulWidget {
  const SuccessDialog({super.key});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.back(); 
        Get.back(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 80,
              ),
            )
                .animate()
                .scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1))
                .then()
                .shake(duration: 400.ms, hz: 2, curve: Curves.easeInOut),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 8),
            const Text(
              'Password changed successfully',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
          ],
        ),
      ),
    );
  }
}
