import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StatsChartWidget extends StatefulWidget {
  final List<int> last7Days;

  const StatsChartWidget({super.key, required this.last7Days});

  @override
  State<StatsChartWidget> createState() => _StatsChartWidgetState();
}

class _StatsChartWidgetState extends State<StatsChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnimation;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );
    _barController.forward();
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  String _dayLabel(int daysAgo) {
    final day = DateTime.now().subtract(Duration(days: daysAgo));
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[day.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = widget.last7Days.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal < 5 ? 20.0 : (maxVal * 1.3).ceilToDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: AppTheme.primaryLight,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7-Day Activity',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Words reviewed per day',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${widget.last7Days.fold(0, (a, b) => a + b)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _barAnimation,
                builder: (_, __) => SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      maxY: safeMax,
                      minY: 0,
                      barTouchData: BarTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (response?.spot != null &&
                                event is! FlTapUpEvent) {
                              _touchedIndex =
                                  response!.spot!.touchedBarGroupIndex;
                            } else {
                              _touchedIndex = null;
                            }
                          });
                        },
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 10,
                          tooltipBgColor: AppTheme.surfaceVariantDark,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()} words',
                              GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryLight,
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
                              final idx = value.toInt();
                              if (idx < 0 || idx >= 7) {
                                return const SizedBox.shrink();
                              }
                              final daysAgo = 6 - idx;
                              final isToday = daysAgo == 0;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  isToday ? 'Today' : _dayLabel(daysAgo),
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: isToday
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: isToday
                                        ? AppTheme.primaryLight
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              if (value == 0 ||
                                  value == safeMax / 2 ||
                                  value == safeMax) {
                                return Text(
                                  value.round().toString(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: AppTheme.textMuted,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: safeMax / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Colors.white.withAlpha(13),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        final isToday = index == 6;
                        final isTouched = _touchedIndex == index;
                        final value =
                            widget.last7Days[index] * _barAnimation.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value.toDouble(),
                              width: 22,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              gradient: LinearGradient(
                                colors: isToday
                                    ? [
                                        AppTheme.primaryLight,
                                        AppTheme.secondary,
                                      ]
                                    : isTouched
                                    ? [
                                        AppTheme.primaryLight.withAlpha(204),
                                        AppTheme.secondary.withAlpha(204),
                                      ]
                                    : [
                                        AppTheme.primary.withAlpha(128),
                                        AppTheme.secondary.withAlpha(77),
                                      ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: safeMax,
                                color: Colors.white.withAlpha(8),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}