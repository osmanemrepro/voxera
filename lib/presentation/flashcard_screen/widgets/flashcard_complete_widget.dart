import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FlashcardCompleteWidget extends StatefulWidget {
  final int reviewedCount;
  final VoidCallback onGoHome;
  final VoidCallback onSeeStats;

  const FlashcardCompleteWidget({
    super.key,
    required this.reviewedCount,
    required this.onGoHome,
    required this.onSeeStats,
  });

  @override
  State<FlashcardCompleteWidget> createState() =>
      _FlashcardCompleteWidgetState();
}

class _FlashcardCompleteWidgetState extends State<FlashcardCompleteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  String _getMessage() {
    if (widget.reviewedCount >= 20) return 'Daily goal smashed! 🏆';
    if (widget.reviewedCount >= 10) return 'Great progress! Keep going!';
    if (widget.reviewedCount > 0) return 'Good start! Come back tomorrow!';
    return 'No words due today!';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1B5E), Color(0xFF1A2A6C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppTheme.glassBorderBright,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryDark,
                              AppTheme.secondaryDark,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(102),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🎯', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Session Complete!',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMessage(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      // Reviewed count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(13),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_stories_rounded,
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.reviewedCount} words reviewed today',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: widget.onGoHome,
                          icon: const Icon(Icons.home_rounded, size: 18),
                          label: Text(
                            'Back to Home',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onSeeStats,
                          icon: const Icon(Icons.bar_chart_rounded, size: 18),
                          label: Text(
                            'View Stats',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryLight,
                            side: BorderSide(
                              color: AppTheme.primaryLight.withAlpha(77),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
