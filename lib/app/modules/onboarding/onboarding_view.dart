import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_controller.dart';
import '../../routes/app_routes.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A237E), 
                  Color(0xFF0D47A1),
                  Color(0xFF006064), 
                ],
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                  duration: const Duration(seconds: 5), color: Colors.white10),

          
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                itemBuilder: (context, index) => const Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          
          SafeArea(
            child: Column(
              children: [
                
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => Get.offAllNamed(Routes.AUTH),
                    child: Text(
                      'SKIP',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    itemCount: controller.pages.length,
                    itemBuilder: (context, index) {
                      final page = controller.pages[index];
                      return _buildPage(context, page);
                    },
                  ),
                ),

                
                _buildBottomControls(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then(delay: 200.ms)
              .shimmer(duration: 1200.ms),

          const SizedBox(height: 60),

          
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ).animate().fadeIn().moveY(begin: 20, end: 0),

          const SizedBox(height: 20),

          
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Obx(() => Row(
                children: List.generate(
                  controller.pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    height: 8,
                    width: controller.currentPage.value == index ? 32 : 8,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == index
                          ? Colors.cyanAccent
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              )),

          
          Obx(() {
            final isLast =
                controller.currentPage.value == controller.pages.length - 1;
            return FloatingActionButton.extended(
              onPressed: controller.nextPage,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A237E),
              label: Text(
                isLast ? 'GET STARTED' : 'NEXT',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              icon: Icon(isLast ? Icons.rocket_launch : Icons.arrow_forward),
            ).animate(target: isLast ? 1 : 0).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 300.ms,
                );
          }),
        ],
      ),
    );
  }
}
