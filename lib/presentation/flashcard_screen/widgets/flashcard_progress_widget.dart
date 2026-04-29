import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FlashcardProgressWidget extends StatelessWidget {
  final int current;
  final int total;

  const FlashcardProgressWidget({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / total).clamp(0.0, 1.0);
    final isNearComplete = progress >= 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Progress',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$current / $total',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isNearComplete
                    ? AppTheme.success
                    : AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withAlpha(18),
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearComplete ? AppTheme.success : AppTheme.primaryLight,
              ),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}
