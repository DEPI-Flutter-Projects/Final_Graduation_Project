import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../profile_controller.dart';

class SpinWheelDialog extends StatefulWidget {
  const SpinWheelDialog({super.key});

  @override
  State<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends State<SpinWheelDialog>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late AnimationController _lightsController;

  final ProfileController controller = Get.find<ProfileController>();
  bool _isSpinning = false;
  int _reward = 0;

  final List<int> rewards = [50, 100, 200, 500, 50, 100, 50, 1000];
  final List<Color> colors = [
    const Color(0xFF4361EE), // Blue
    const Color(0xFF7209B7), // Purple
    const Color(0xFFF72585), // Pink
    const Color(0xFF4CC9F0), // Light Blue
    const Color(0xFFFFD93D), // Yellow
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF6BCB77), // Green
    const Color(0xFF4D96FF), // Azure
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.decelerate,
    );

    _lightsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _lightsController.dispose();
    super.dispose();
  }

  void _spin() async {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);

    _reward = await controller.spinWheel();

    if (_reward == 0) {
      Get.back();
      return;
    }

    final matchingIndices = <int>[];
    for (int i = 0; i < rewards.length; i++) {
      if (rewards[i] == _reward) matchingIndices.add(i);
    }
    final targetIndex =
        matchingIndices[Random().nextInt(matchingIndices.length)];

    final segmentAngle = 2 * pi / rewards.length;

    // Add extra rotations for suspense (5 to 10 full spins)
    const totalRotations = 8 * 2 * pi;

    // Calculate precise angle to land on the center of the segment
    // We adjust by -pi/2 because typically 0 is at 3 o'clock, but our pointer is at 12 o'clock (-pi/2)
    // Actually, usually 0 is East. We want to land at North (-pi/2).
    // The painter starts drawing segment 0 at -pi/2 - segmentAngle/2.
    // Let's rely on standard calculation: targetAngle = totalRotations + (distance to target)

    final randomOffset = (Random().nextDouble() - 0.5) * segmentAngle * 0.8;

    // The pointer is at the TOP (270 degrees or -pi/2).
    // If the wheel rotates CLOCKWISE, to bring index i to the top, we need to rotate by:
    // Angle to Top - Angle of Index i
    final indexAngle = (targetIndex * segmentAngle);
    final distanceToTravel = (2 * pi) - indexAngle;

    final targetAngle = totalRotations + distanceToTravel + randomOffset;

    _spinAnimation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(
          parent: _spinController,
          curve: Curves
              .easeOutCubic // Cubic out feels more like a heavy wheel slowing down
          ),
    );

    _spinController.forward(from: 0).then((_) {
      _showWinDialog();
    });
  }

  void _showWinDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark Slate
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
                color: Colors.amber.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti/Star Burst Effect using Flutter Animate
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.stars_rounded,
                            size: 80, color: Colors.amber)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                            duration: 800.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2))
                        .shimmer(duration: 1200.ms, color: Colors.white),
                    // Simple particles using icons
                    ...List.generate(6, (index) {
                      final angle = (index * 60) * pi / 180;
                      return Positioned(
                        child: const Icon(Icons.star,
                                size: 20, color: Colors.yellowAccent)
                            .animate()
                            .move(
                                duration: 800.ms,
                                begin: const Offset(0, 0),
                                end: Offset(cos(angle) * 60, sin(angle) * 60),
                                curve: Curves.easeOutBack)
                            .fadeOut(delay: 500.ms),
                      );
                    })
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('CONGRATULATIONS!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent)),
              const SizedBox(height: 8),
              Text('You won $_reward XP!',
                      style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white))
                  .animate()
                  .scale(curve: Curves.elasticOut, duration: 800.ms),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                ),
                child: const Text('Collect Reward',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ).animate().shimmer(
                  duration: const Duration(seconds: 2),
                  delay: const Duration(seconds: 1)),
            ],
          ),
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Dark Background
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Spin',
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                            color: Colors.purpleAccent.withValues(alpha: 0.5),
                            blurRadius: 10)
                      ]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Spin to win XP rewards!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 32),

                // The Wheel Frame
                SizedBox(
                  height: 320,
                  width: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Border Lights Ring
                      AnimatedBuilder(
                        animation: _lightsController,
                        builder: (context, child) {
                          return Container(
                            width: 310,
                            height: 310,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF334155), width: 14),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black45, blurRadius: 10)
                                ]),
                            child: CustomPaint(
                              painter: LightsPainter(_lightsController.value),
                            ),
                          );
                        },
                      ),

                      // The Spinning Wheel
                      AnimatedBuilder(
                        animation: _spinAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinAnimation.value,
                            child: Container(
                              width: 280,
                              height: 280,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black26, blurRadius: 10)
                                  ]),
                              child: CustomPaint(
                                painter: WheelPainter(rewards, colors),
                              ),
                            ),
                          );
                        },
                      ),

                      // Pointer (at Top)
                      Positioned(
                        top: -10,
                        child: Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.amber, Colors.orangeAccent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]),
                          child: const Icon(Icons.arrow_drop_down,
                              color: Colors.white, size: 36),
                        ).animate().slideY(
                            begin: -0.5,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutBack),
                      ),

                      // Center Button
                      GestureDetector(
                        onTap: _isSpinning ? null : _spin,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSpinning
                                  ? [Colors.grey.shade400, Colors.grey.shade600]
                                  : [
                                      const Color(0xFFF72585),
                                      const Color(0xFF7209B7)
                                    ], // Pink to Purple
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _isSpinning
                                    ? Colors.transparent
                                    : Colors.purpleAccent
                                        .withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isSpinning ? '...' : 'SPIN',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        )
                            .animate(
                                onPlay: (c) => _isSpinning
                                    ? c.stop()
                                    : c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: const Duration(seconds: 1),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom Button
                if (!_isSpinning)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _spin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2))),
                      ),
                      child: const Text(
                        'TRY YOUR LUCK',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<int> rewards;
  final List<Color> colors;

  WheelPainter(this.rewards, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final anglePerSegment = 2 * pi / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle =
          (i * anglePerSegment) - (pi / 2) - (anglePerSegment / 2);

      // Gradient for each segment
      final segmentPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i % colors.length],
            colors[i % colors.length]
                .withValues(alpha: 0.8), // Darker outer edge
          ],
          stops: const [0.6, 1.0],
          center: Alignment.center,
          radius: 1.0,
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw Segment
      canvas.drawArc(rect, startAngle, anglePerSegment, true, segmentPaint);
      canvas.drawArc(rect, startAngle, anglePerSegment, true, borderPaint);

      _drawText(canvas, size, rewards[i].toString(), i, anglePerSegment, radius,
          startAngle);
    }
  }

  void _drawText(Canvas canvas, Size size, String text, int index,
      double anglePerSegment, double radius, double startAngle) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            shadows: [
              const BoxShadow(
                  color: Colors.black45, blurRadius: 2, offset: Offset(1, 1))
            ]),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Center of the segment angle
    final angle = startAngle + (anglePerSegment / 2);

    final offset = Offset(
      size.width / 2 + (radius * 0.65) * cos(angle),
      size.height / 2 + (radius * 0.65) * sin(angle),
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle + pi / 2); // Rotate text to face center
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LightsPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  LightsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2); // On the border

    // Total lights
    const count = 24;
    const angleStep = (2 * pi) / count;

    for (int i = 0; i < count; i++) {
      final angle = i * angleStep;
      final lightPos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Creating a blinking effect
      // Odd lights on when progress > 0.5, Even on when progress < 0.5
      final isEven = i % 2 == 0;
      final isOn = isEven ? progress < 0.5 : progress >= 0.5;

      final paint = Paint()
        ..color =
            isOn ? Colors.yellowAccent : Colors.orange.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      // Glow effect if on
      if (isOn) {
        canvas.drawCircle(
            lightPos,
            6,
            Paint()
              ..color = Colors.yellow.withValues(alpha: 0.4)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }

      canvas.drawCircle(lightPos, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LightsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
