import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class ChartGuideDialog extends StatefulWidget {
  final String title;
  final String chartType; // 'savings', 'trend', 'mode'

  const ChartGuideDialog({
    super.key,
    required this.title,
    required this.chartType,
  });

  @override
  State<ChartGuideDialog> createState() => _ChartGuideDialogState();
}

class _ChartGuideDialogState extends State<ChartGuideDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<GuideStep> get _steps {
    switch (widget.chartType) {
      case 'savings':
        return [
          GuideStep(
            title: 'Money vs. Trips',
            description:
                'Vertical bars represent your data. The taller the bar, the higher the value.',
            chartBuilder: (animate) => _buildSavingsStep1(animate),
          ),
          GuideStep(
            title: 'Color Meaning',
            description:
                'Green bars show Total Money Saved. Blue bars show Total Number of Trips.',
            chartBuilder: (animate) => _buildSavingsStep2(animate),
          ),
          GuideStep(
            title: 'Interactive Details',
            description:
                'Tap on any bar to see the exact amount saved or number of trips for that period.',
            chartBuilder: (animate) => _buildSavingsStep3(animate),
          ),
        ];
      case 'trend':
        return [
          GuideStep(
            title: 'Savings Trajectory',
            description:
                'The line shows how your savings have evolved over time.',
            chartBuilder: (animate) => _buildTrendStep1(animate),
          ),
          GuideStep(
            title: 'Consistency Check',
            description:
                'A steady upward curve means you are saving consistently.',
            chartBuilder: (animate) => _buildTrendStep2(animate),
          ),
          GuideStep(
            title: 'Track Performance',
            description:
                'Peaks indicate high saving days, while dips show days with less activity.',
            chartBuilder: (animate) => _buildTrendStep3(animate),
          ),
        ];
      case 'mode':
        return [
          GuideStep(
            title: 'Consumption Breakdown',
            description: 'See which transport modes you use the most.',
            chartBuilder: (animate) => _buildModeStep1(animate),
          ),
          GuideStep(
            title: 'Tap to Explore',
            description:
                'Tap a slice to focus on it. The center text will update with details.',
            chartBuilder: (animate) => _buildModeStep2(animate),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPages = _steps.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: theme.hintColor),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: step.chartBuilder(index == _currentPage),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          step.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 12),
                        Text(
                          step.description,
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.5),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(totalPages, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : theme.disabledColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  // Navigation Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < totalPages - 1) {
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
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentPage < totalPages - 1 ? 'Next' : 'Got it',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Chart Builders ---

  Widget _buildSavingsStep1(bool animate) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: animate ? 1 : 0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return BarChart(
          BarChartData(
            barGroups: [
              _makeGroupData(0, 5 * value, isGreen: true),
              _makeGroupData(1, 8 * value, isGreen: true),
              _makeGroupData(2, 6 * value, isGreen: true),
            ],
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            maxY: 10,
          ),
        );
      },
    );
  }

  Widget _buildSavingsStep2(bool animate) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: animate ? 1 : 0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            barGroups: [
              _makeGroupData(0, 5, isGreen: true),
              _makeGroupData(1, 3 * value, isGreen: false), // Blue bar
              _makeGroupData(2, 8, isGreen: true),
              _makeGroupData(3, 4 * value, isGreen: false), // Blue bar
            ],
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            maxY: 10,
          ),
        );
      },
    );
  }

  Widget _buildSavingsStep3(bool animate) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BarChart(
          BarChartData(
            barGroups: [
              _makeGroupData(0, 5, isGreen: true, isTouched: true),
              _makeGroupData(1, 8, isGreen: true),
              _makeGroupData(2, 6, isGreen: true),
            ],
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            maxY: 10,
          ),
        ),
        if (animate)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Text('250 EGP', style: TextStyle(color: Colors.white)),
            ).animate().fadeIn().moveY(begin: 10, end: 0),
          ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y,
      {bool isGreen = true, bool isTouched = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isTouched
              ? Colors.amber
              : (isGreen ? AppColors.success : AppColors.primary),
          // Gradient for realism
          gradient: isTouched
              ? null
              : LinearGradient(
                  colors: isGreen
                      ? [
                          AppColors.success,
                          AppColors.success.withValues(alpha: 0.7)
                        ]
                      : [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7)
                        ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildTrendStep1(bool animate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.accent : AppColors.primary;
    final gradientColors = isDark
        ? [AppColors.accent, AppColors.successLight]
        : [AppColors.primary, AppColors.secondary];

    return TweenAnimationBuilder<double>(
      tween:
          Tween(begin: 0, end: animate ? 5 : 0), // Animate X-axis range/spots
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutCubic, // Smoother curve
      builder: (context, value, child) {
        final allSpots = [
          const FlSpot(0, 1),
          const FlSpot(1, 3),
          const FlSpot(2, 2),
          const FlSpot(3, 5),
          const FlSpot(4, 4),
        ];

        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: value / 5,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: allSpots,
                    isCurved: true,
                    // Rich Gradient Stroke
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 5, // Thicker curve
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withValues(alpha: isDark ? 0.2 : 0.3),
                          lineColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendStep2(bool animate) {
    // Step 2 uses Green (Success) which is usually fine in Dark Mode,
    // but we ensure it pops.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.successLight : AppColors.success;

    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: animate ? 1.0 : 0.0),
        duration: const Duration(seconds: 1),
        builder: (context, value, child) {
          return LineChart(
            LineChartData(
              minX: 0,
              maxX: 4,
              minY: 0,
              maxY: 6,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 1),
                    const FlSpot(1, 2),
                    const FlSpot(2, 3),
                    const FlSpot(3, 4),
                    const FlSpot(4, 5),
                  ],
                  isCurved: true,
                  color: lineColor,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        lineColor.withValues(alpha: 0.3 * value),
                        lineColor.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              titlesData: const FlTitlesData(show: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          );
        });
  }

  Widget _buildTrendStep3(bool animate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.accent : AppColors.primary;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 4,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 2),
              const FlSpot(1, 5), // Peak
              const FlSpot(2, 1), // Dip
              const FlSpot(3, 4),
            ],
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.y == 5 || spot.y == 1,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor:
                        spot.y == 5 ? AppColors.success : AppColors.error,
                  );
                }),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  lineColor.withValues(alpha: isDark ? 0.2 : 0.2),
                  lineColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    ).animate(target: animate ? 1 : 0).scale(
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  Widget _buildModeStep1(bool animate) {
    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: animate ? 1 : 0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                    color: AppColors.carColor,
                    value: 40,
                    radius: 40 * value,
                    showTitle: false),
                PieChartSectionData(
                    color: AppColors.metroColor,
                    value: 30,
                    radius: 40 * value,
                    showTitle: false),
                PieChartSectionData(
                    color: AppColors.microbusColor,
                    value: 20,
                    radius: 40 * value,
                    showTitle: false),
                PieChartSectionData(
                    color: Colors.green,
                    value: 10,
                    radius: 40 * value,
                    showTitle: false),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              startDegreeOffset: 270 * value, // Spin effect
            ),
          );
        });
  }

  Widget _buildModeStep2(bool animate) {
    // Static chart but with highlight
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
              color: AppColors.carColor,
              value: 40,
              radius: 50,
              showTitle: false), // Touched
          PieChartSectionData(
              color: AppColors.metroColor,
              value: 30,
              radius: 40,
              showTitle: false),
          PieChartSectionData(
              color: AppColors.microbusColor,
              value: 20,
              radius: 40,
              showTitle: false),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    )
        .animate(target: animate ? 1 : 0)
        .scale(duration: const Duration(milliseconds: 400));
  }
}

class GuideStep {
  final String title;
  final String description;
  final Widget Function(bool animate) chartBuilder;

  GuideStep({
    required this.title,
    required this.description,
    required this.chartBuilder,
  });
}
