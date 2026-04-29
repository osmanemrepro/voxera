import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class StatsKpiRowWidget extends StatelessWidget {
  final int learnedCount;
  final int streak;
  final double accuracy;
  final int totalWords;

  const StatsKpiRowWidget({
    super.key,
    required this.learnedCount,
    required this.streak,
    required this.accuracy,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    final masteryPct = totalWords > 0
        ? ((learnedCount / totalWords) * 100).round()
        : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.check_circle_rounded,
                iconColor: AppTheme.success,
                value: '$learnedCount',
                label: 'Words Learned',
                sublabel: 'of $totalWords total',
                isHighlight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFF97316),
                value: '$streak',
                label: 'Day Streak',
                sublabel: streak >= 7 ? '🏆 On fire!' : 'Keep going!',
                isHighlight: streak >= 7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.track_changes_rounded,
                iconColor: accuracy < 0.5 && learnedCount > 0
                    ? AppTheme.warning
                    : AppTheme.secondary,
                value: '${(accuracy * 100).round()}%',
                label: 'Accuracy',
                sublabel: accuracy < 0.5 && learnedCount > 0
                    ? '⚠ Needs work'
                    : 'Today',
                isWarning: accuracy < 0.5 && learnedCount > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                icon: Icons.school_rounded,
                iconColor: AppTheme.primaryLight,
                value: '$masteryPct%',
                label: 'Mastery',
                sublabel: 'of vocabulary',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String sublabel;
  final bool isHighlight;
  final bool isWarning;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sublabel,
    this.isHighlight = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isWarning
                ? AppTheme.warningSurface
                : isHighlight
                ? AppTheme.primary.withAlpha(26)
                : AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isWarning
                  ? AppTheme.warning.withAlpha(64)
                  : isHighlight
                  ? AppTheme.primary.withAlpha(64)
                  : AppTheme.glassBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isWarning
                            ? AppTheme.warning
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
