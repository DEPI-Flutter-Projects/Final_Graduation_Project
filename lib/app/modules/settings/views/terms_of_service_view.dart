import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Terms of Service',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastUpdated(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using the El-Meshwar application, you accept and agree to be bound by the terms and provision of this agreement. In addition, when using this App\'s particular services, you shall be subject to any posted guidelines or rules applicable to such services.',
            ),
            _buildSection(
              context,
              '2. Services Description',
              'El-Meshwar provides users with route planning, fuel cost estimation, and vehicle management tools. You acknowledge that:\n\n• Route estimates (time, distance, cost) are approximations based on available data and may not reflect real-time conditions.\n• Fuel cost calculations are estimates and actual consumption may vary based on driving habits, vehicle condition, and road conditions.',
            ),
            _buildSection(
              context,
              '3. User Conduct & Safety',
              'You agree to use the App responsibly and in compliance with all applicable traffic laws and regulations.\n\n• Do not interact with the App while driving.\n• You are solely responsible for your safety and the safety of others while operating a vehicle.\n• El-Meshwar is not liable for any traffic violations, accidents, or damages resulting from your use of the App.',
            ),
            _buildSection(
              context,
              '4. Location Data',
              'The App requires access to your device\'s location to provide navigation and route planning services. By using the App, you consent to the collection and use of your location data as described in our Privacy Policy.',
            ),
            _buildSection(
              context,
              '5. Intellectual Property',
              'The App and its original content, features, and functionality are owned by El-Meshwar and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.',
            ),
            _buildSection(
              context,
              '6. Limitation of Liability',
              'In no event shall El-Meshwar, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the App.',
            ),
            _buildSection(
              context,
              '7. Modifications to Service',
              'We reserve the right to modify or discontinue, temporarily or permanently, the App (or any part thereof) with or without notice. We shall not be liable to you or to any third party for any modification, price change, suspension or discontinuance of the Service.',
            ),
            _buildSection(
              context,
              '8. Governing Law',
              'These Terms shall be governed and construed in accordance with the laws of Egypt, without regard to its conflict of law provisions.',
            ),
            const SizedBox(height: 32),
            _buildContactInfo(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Last Updated: December 2025',
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Text(
            'Questions about our Terms?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact our legal team',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Add email launch logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('legal@elmeshwar.com'),
          ),
        ],
      ),
    );
  }
}
