import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/analysis_controller.dart';
import '../../settings/settings_controller.dart';

class AnalysisView extends GetView<AnalysisController> {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Analysis & Insights',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.iconTheme.color, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Last Week'),
                  const SizedBox(width: 12),
                  _buildFilterChip('Last Month'),
                  const SizedBox(width: 12),
                  _buildFilterChip('All Time'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final settings = Get.find<SettingsController>();
              String currency = settings.currency.value;
              double rate = settings.exchangeRate.value;

              double saved = controller.totalSaved.value * rate;
              double avg = controller.avgSaved.value * rate;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Saved',
                          '$currency ${saved.toStringAsFixed(0)}',
                          Icons.savings_outlined,
                          AppColors.success,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Trips',
                          '${controller.totalTrips.value}',
                          Icons.directions_car_outlined,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Avg. Savings',
                          '$currency ${avg.toStringAsFixed(1)}',
                          Icons.analytics_outlined,
                          Colors.orange,
                          subtitle: 'per trip',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricTab('Money Saved'),
                      const SizedBox(width: 12),
                      _buildMetricTab('Trips'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBarChart(context),
                  const SizedBox(height: 32),
                  _buildTrendChart(context),
                  const SizedBox(height: 32),
                  _buildModeChart(context),
                  const SizedBox(height: 32),
                ],
              )
                  .animate()
                  .fadeIn()
                  .scale(delay: const Duration(milliseconds: 200));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.savingsTrendData.isEmpty) {
          return const Center(child: Text('No data available'));
        }
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: controller.savingsTrendData,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.white,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipBorder:
                    BorderSide(color: Theme.of(context).dividerColor),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final settings = Get.find<SettingsController>();
                    String currency = settings.currency.value;
                    double rate = settings.exchangeRate.value;

                    return LineTooltipItem(
                      '$currency ${(spot.y * rate).toStringAsFixed(0)}',
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildModeChart(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.transportModeData.isEmpty) {
          return const Center(child: Text('No data available'));
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      controller.setTouchedIndex(-1);
                      return;
                    }
                    controller.setTouchedIndex(
                        pieTouchResponse.touchedSection!.touchedSectionIndex);
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 70,
                sections: controller.transportModeData.asMap().entries.map((e) {
                  final index = e.key;
                  final data = e.value;
                  final isTouched = index == controller.touchedIndex.value;
                  final fontSize = isTouched ? 18.0 : 14.0;
                  final radius = isTouched ? 60.0 : 50.0;

                  return PieChartSectionData(
                    color: _getModeColor(data['mode']),
                    value: (data['count'] as int).toDouble(),
                    title:
                        '${(data['percentage'] as double).toStringAsFixed(0)}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
            Obx(() {
              final touchedIndex = controller.touchedIndex.value;
              String centerText = 'Total\nTrips';
              String subText = '${controller.totalTrips.value}';

              if (touchedIndex != -1 &&
                  touchedIndex < controller.transportModeData.length) {
                final data = controller.transportModeData[touchedIndex];
                centerText = data['mode'];
                subText =
                    '${(data['percentage'] as double).toStringAsFixed(1)}%';
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                  ),
                ],
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.chartData.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final isMoney = controller.selectedMetric.value == 'Money Saved';
        final gradientColors = isMoney
            ? [AppColors.success, AppColors.success.withValues(alpha: 0.6)]
            : [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)];

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.white,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipBorder: BorderSide(color: Colors.grey.shade200),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final settings = Get.find<SettingsController>();
                  String currency = settings.currency.value;
                  double rate = settings.exchangeRate.value;

                  String valueStr;
                  if (isMoney) {
                    valueStr =
                        '$currency ${(rod.toY * rate).toStringAsFixed(0)}';
                  } else {
                    valueStr = '${rod.toY.toInt()} trips';
                  }

                  return BarTooltipItem(
                    valueStr,
                    const TextStyle(
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < controller.chartData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          controller.chartData[value.toInt()]['label'],
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: controller.chartData.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: (e.value['value'] as num).toDouble(),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 16,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'car':
        return AppColors.carColor;
      case 'metro':
        return AppColors.metroColor;
      case 'microbus':
        return AppColors.microbusColor;
      case 'bus':
        return Colors.blue;
      case 'walking':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getMaxY() {
    if (controller.chartData.isEmpty) return 100;
    double max = 0;
    for (var item in controller.chartData) {
      if ((item['value'] as num) > max) max = (item['value'] as num).toDouble();
    }
    return max * 1.2;
  }

  Widget _buildFilterChip(String label) {
    return Obx(() {
      final isSelected = controller.selectedTimeRange.value == label;
      return GestureDetector(
        onTap: () => controller.setTimeRange(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Theme.of(Get.context!).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(Get.context!).dividerColor,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(Get.context!).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMetricTab(String label) {
    return GestureDetector(
      onTap: () => controller.setMetric(label),
      child: Obx(() {
        final isSelected = controller.selectedMetric.value == label;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Theme.of(Get.context!).textTheme.bodyLarge?.color
                  : Theme.of(Get.context!).disabledColor,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color,
      {bool isPrimary = false, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary : Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPrimary
                    ? AppColors.primary
                    : Theme.of(Get.context!).shadowColor)
                .withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(icon, color: isPrimary ? Colors.white : color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPrimary
                  ? Colors.white
                  : Theme.of(Get.context!).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.8)
                  : Theme.of(Get.context!).textTheme.bodyMedium?.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.6)
                    : Theme.of(Get.context!).textTheme.bodySmall?.color,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}
