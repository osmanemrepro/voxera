import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class HomeStatsRowWidget extends StatelessWidget {
  final int streak;
  final int learnedCount;
  final double accuracy;

  const HomeStatsRowWidget({
    super.key,
    required this.streak,
    required this.learnedCount,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFF97316),
            label: 'Streak',
            value: '$streak days',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppTheme.success,
            label: 'Learned',
            value: '$learnedCount words',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.track_changes_rounded,
            iconColor: AppTheme.secondary,
            label: 'Accuracy',
            value: '${(accuracy * 100).round()}%',
            isWarning: accuracy < 0.5 && learnedCount > 0,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isWarning;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isWarning ? AppTheme.warningSurface : AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWarning
                  ? AppTheme.warning.withAlpha(64)
                  : AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
