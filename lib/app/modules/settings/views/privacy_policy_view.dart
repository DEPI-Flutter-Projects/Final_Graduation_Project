import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimaryLight, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Introduction',
              'Welcome to El-Meshwar. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you as to how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.',
            ),
            _buildSection(
              '2. Data We Collect',
              'We may collect, use, store and transfer different kinds of personal data about you which we have grouped together follows:\n\n• Identity Data: includes first name, last name, username or similar identifier.\n• Contact Data: includes email address and telephone number.\n• Location Data: includes your real-time location to provide route tracking and optimization services.\n• Transaction Data: includes details about payments to and from you and other details of products and services you have purchased from us.',
            ),
            _buildSection(
              '3. How We Use Your Data',
              'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n• To provide the services you have requested, such as route planning and cost estimation.\n• To manage our relationship with you.\n• To improve our website, products/services, marketing, customer relationships and experiences.',
            ),
            _buildSection(
              '4. Data Security',
              'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorized way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know.',
            ),
            _buildSection(
              '5. Your Legal Rights',
              'Under certain circumstances, you have rights under data protection laws in relation to your personal data, including the right to request access, correction, erasure, restriction, transfer, to object to processing, to portability of data and (where the lawful ground of processing is consent) to withdraw consent.',
            ),
            _buildSection(
              '6. Contact Us',
              'If you have any questions about this privacy policy or our privacy practices, please contact us at support@elmeshwar.com.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Last Updated: December 2025',
                style: TextStyle(
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
