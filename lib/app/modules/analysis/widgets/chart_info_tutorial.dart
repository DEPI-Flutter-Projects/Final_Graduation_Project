import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class ChartInfoTutorial extends StatefulWidget {
  final String chartType; 

  const ChartInfoTutorial({super.key, required this.chartType});

  @override
  State<ChartInfoTutorial> createState() => _ChartInfoTutorialState();
}

class _ChartInfoTutorialState extends State<ChartInfoTutorial> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        height: 450,
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
          children: [
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.chartType == 'Trend'
                        ? 'Savings Trend'
                        : widget.chartType == 'Mode'
                            ? 'Transport Modes'
                            : 'Breakdown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Row(
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentPage < 2 ? 'Next' : 'Got it',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildPage1() {
    String title = 'What is this?';
    String description = '';

    if (widget.chartType == 'Trend') {
      description =
          'This chart tracks your cumulative savings over time. It shows how much money you have saved by choosing cheaper transport options.';
    } else if (widget.chartType == 'Mode') {
      description =
          'This chart shows the distribution of transport modes you use. It helps you understand your travel habits.';
    } else if (widget.chartType == 'Breakdown') {
      description =
          'This chart breaks down your data by day or month. You can switch between "Money Saved" and "Trips" to see different perspectives.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline,
                    size: 48, color: AppColors.primary),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage2() {
    String title = 'How to read it?';
    String description = '';
    CustomPainter painter;

    if (widget.chartType == 'Trend') {
      description =
          'The line goes UP when you save money. A steeper line means you are saving faster!';
      painter = _TrendPainter();
    } else if (widget.chartType == 'Mode') {
      description =
          'Each slice represents a transport mode. The bigger the slice, the more you use that mode.';
      painter = _PiePainter();
    } else {
      description =
          'Taller bars mean more savings or more trips. Compare the bars to see which days were most productive.';
      painter = _BarPainter();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Container(
                height: 150,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: CustomPaint(
                  painter: painter,
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage3() {
    String title = 'Insights';
    String description = '';

    if (widget.chartType == 'Trend') {
      description =
          'Use this to set goals! Try to keep the line moving up steadily to maximize your monthly savings.';
    } else if (widget.chartType == 'Mode') {
      description =
          'Check if you are relying too much on expensive modes like Car. Try to increase the "Metro" or "Bus" slices to save more.';
    } else {
      description =
          'Identify patterns in your travel. Do you save more on weekends? Do you take more trips on weekdays?';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline,
                    size: 48, color: Colors.green),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.8, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);

    
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(0, size.height), 6, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.2), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PiePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint1 = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    final paint3 = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    
    canvas.drawArc(rect, -1.5, 2.5, true, paint1); 
    canvas.drawArc(rect, 1.0, 2.0, true, paint2); 
    canvas.drawArc(rect, 3.0, 1.8, true, paint3); 
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 5;

    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            barWidth * 0.5, size.height * 0.4, barWidth, size.height * 0.6),
        const Radius.circular(4),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            barWidth * 2.0, size.height * 0.2, barWidth, size.height * 0.8),
        const Radius.circular(4),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            barWidth * 3.5, size.height * 0.6, barWidth, size.height * 0.4),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
