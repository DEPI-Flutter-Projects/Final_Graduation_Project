import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../home_controller.dart';
import '../../settings/settings_controller.dart';

class SavedDetailsDialog extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();
  final SettingsController settings = Get.find<SettingsController>();

  SavedDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.savings_rounded,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Savings Breakdown',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'This Month vs Last Month',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close,
                      color: AppColors.textTertiaryLight),
                ),
              ],
            ),
            const SizedBox(height: 32),

            
            Obx(() {
              final currency = settings.currency.value;
              final rate = settings.exchangeRate.value;
              final thisMonth = controller.moneySavedThisMonth.value * rate;
              final lastMonth = controller.moneySavedLastMonth.value * rate;

              final diff = thisMonth - lastMonth;
              final isPositive = diff >= 0;

              return Column(
                children: [
                  _buildStatRow('This Month', thisMonth, currency, true),
                  const SizedBox(height: 16),
                  _buildStatRow('Last Month', lastMonth, currency, false),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Difference',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              (isPositive ? AppColors.success : AppColors.error)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: isPositive
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${isPositive ? '+' : ''}${diff.toStringAsFixed(2)} $currency',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: isPositive
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: 32),

            
            Obx(() {
              final goal = controller.savingsGoal.value;
              final current = controller.moneySavedThisMonth.value *
                  settings.exchangeRate.value;
              final progress = (current / goal).clamp(0.0, 1.0);
              final currency = settings.currency.value;

              return Column(
                children: [
                  SizedBox(
                    height: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (progress * 100).toInt(),
                            child: Container(color: AppColors.primary),
                          ),
                          Expanded(
                            flex: ((1 - progress) * 100).toInt(),
                            child: Container(
                                color: AppColors.textTertiaryLight
                                    .withValues(alpha: 0.3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progress * 100).toStringAsFixed(0)}% of goal',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight)),
                      Text('Goal: ${goal.toStringAsFixed(0)} $currency',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/analysis'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View Detailed Analysis',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Obx(() => controller.debugLog.value.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    width: double.infinity,
                    child: Text(
                      controller.debugLog.value,
                      style: GoogleFonts.robotoMono(fontSize: 10),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildStatRow(
      String label, double amount, String currency, bool isHighlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} $currency',
          style: GoogleFonts.outfit(
            fontSize: isHighlight ? 24 : 18,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color:
                isHighlight ? AppColors.primary : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}
