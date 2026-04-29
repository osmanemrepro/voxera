import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class HomeHeaderWidget extends StatelessWidget {
  final int streak;
  final bool isAdmin;
  final VoidCallback? onAdminTap;

  const HomeHeaderWidget({
    super.key,
    required this.streak,
    this.isAdmin = false,
    this.onAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voxera',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Kelime öğrenme zamanı 📚',
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (isAdmin)
          GestureDetector(
            onTap: onAdminTap,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Admin',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
