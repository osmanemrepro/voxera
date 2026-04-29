import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum BadgeStatus { known, learning, weak, newWord, mastered }

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;

  const StatusBadgeWidget({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$3,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.$2.withAlpha(77), width: 1),
      ),
      child: Text(
        customLabel ?? config.$1,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.$2,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (String, Color, Color) _getConfig() {
    switch (status) {
      case BadgeStatus.known:
        return ('Known', AppTheme.success, AppTheme.successSurface);
      case BadgeStatus.learning:
        return ('Learning', AppTheme.secondary, const Color(0x1A3B82F6));
      case BadgeStatus.weak:
        return ('Weak', AppTheme.error, AppTheme.errorSurface);
      case BadgeStatus.newWord:
        return ('New', AppTheme.primaryLight, const Color(0x1AA78BFA));
      case BadgeStatus.mastered:
        return ('Mastered', AppTheme.warning, AppTheme.warningSurface);
    }
  }
}
