import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../profile_controller.dart';

class SpinWheelDialog extends StatefulWidget {
  const SpinWheelDialog({super.key});

  @override
  State<SpinWheelDialog> createState() => _SpinWheelDialogState();
}

class _SpinWheelDialogState extends State<SpinWheelDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  final ProfileController controller = Get.find<ProfileController>();
  bool _isSpinning = false;
  int _reward = 0;

  final List<int> rewards = [50, 100, 200, 500, 50, 100, 50, 1000];
  final List<Color> colors = [
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.teal,
    Colors.indigo,
    Colors.amber
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.decelerate,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
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

    
    
    
    
    
    
    

    final randomOffset = Random().nextDouble() *
        segmentAngle *
        0.8; 
    final totalRotations = 5 * 2 * pi; 
    final targetAngle = totalRotations +
        ((rewards.length - targetIndex) * segmentAngle) +
        randomOffset;

    _animation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward(from: 0).then((_) {
      _showWinDialog();
    });
  }

  void _showWinDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: Colors.amber)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text('CONGRATULATIONS!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
              const SizedBox(height: 8),
              Text('You won $_reward XP!',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back(); 
                  Get.back(); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Collect',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Daily Spin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value,
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: WheelPainter(rewards, colors),
                            ),
                          );
                        },
                      ),
                      
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 30,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_drop_down,
                              color: Colors.white, size: 30),
                        ),
                      ),
                      
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SPIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isSpinning ? Colors.grey : Colors.purple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSpinning ? null : _spin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSpinning ? 'Spinning...' : 'SPIN NOW',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
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
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      
      
      
      

      canvas.drawArc(
        rect,
        (i * anglePerSegment) - (pi / 2) - (anglePerSegment / 2),
        anglePerSegment,
        true,
        paint,
      );

      
      _drawText(
          canvas, size, rewards[i].toString(), i, anglePerSegment, radius);
    }
  }

  void _drawText(Canvas canvas, Size size, String text, int index,
      double anglePerSegment, double radius) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final angle = (index * anglePerSegment) - (pi / 2);
    final offset = Offset(
      size.width / 2 + (radius * 0.7) * cos(angle),
      size.height / 2 + (radius * 0.7) * sin(angle),
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle + pi / 2); 
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
