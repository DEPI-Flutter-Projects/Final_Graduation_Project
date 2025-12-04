import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), 
              Color(0xFF0D47A1), 
              Color(0xFF000000), 
            ],
          ),
        ),
        child: Stack(
          children: [
            
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.1),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withValues(alpha: 0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1.1, 1.1),
                              duration: 2000.ms,
                              curve: Curves.easeInOut),

                      
                      Image.asset(
                        'assets/logo/El_Meshwar.png',
                        width: 120,
                        height: 120,
                      )
                          .animate()
                          .scale(
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                              begin: const Offset(0.5, 0.5))
                          .then()
                          .shimmer(duration: 1500.ms, delay: 500.ms),
                    ],
                  ),

                  const SizedBox(height: 40),

                  
                  Text(
                    'El-Meshwar',
                    style: GoogleFonts.outfit(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms).moveY(
                      begin: 20,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  
                  Text(
                    'Your Smart Route Companion',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 600.ms)
                      .moveY(begin: 10, end: 0),

                  const SizedBox(height: 60),

                  
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade300,
                      ),
                      strokeWidth: 3,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
