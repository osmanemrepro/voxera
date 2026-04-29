import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class HomeGoalCardWidget extends StatefulWidget {
  final int todayCount;
  final int dailyGoal;
  final VoidCallback onStartReview;

  const HomeGoalCardWidget({
    super.key,
    required this.todayCount,
    required this.dailyGoal,
    required this.onStartReview,
  });

  @override
  State<HomeGoalCardWidget> createState() => _HomeGoalCardWidgetState();
}

class _HomeGoalCardWidgetState extends State<HomeGoalCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation =
        Tween<double>(
          begin: 0,
          end: (widget.todayCount / widget.dailyGoal).clamp(0.0, 1.0),
        ).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.todayCount >= widget.dailyGoal;
    final remaining = (widget.dailyGoal - widget.todayCount).clamp(
      0,
      widget.dailyGoal,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1B5E), Color(0xFF1A2A6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.glassBorderBright, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(51),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background glow orb
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondary.withAlpha(31),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isComplete
                                      ? AppTheme.successSurface
                                      : AppTheme.primary.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isComplete
                                        ? AppTheme.success.withAlpha(77)
                                        : AppTheme.primary.withAlpha(77),
                                  ),
                                ),
                                child: Text(
                                  isComplete ? '✓ Completed' : 'Daily Goal',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isComplete
                                        ? AppTheme.success
                                        : AppTheme.primaryLight,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.todayCount}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ${widget.dailyGoal}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textMuted,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isComplete
                                ? 'Goal achieved! 🎉'
                                : '$remaining words remaining',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Progress bar
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (_, __) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: _progressAnimation.value,
                                    backgroundColor: Colors.white.withAlpha(20),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isComplete
                                          ? AppTheme.success
                                          : AppTheme.primaryLight,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: widget.onStartReview,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isComplete
                                    ? const LinearGradient(
                                        colors: [
                                          AppTheme.success,
                                          Color(0xFF059669),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          AppTheme.primaryDark,
                                          AppTheme.secondaryDark,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isComplete
                                                ? AppTheme.success
                                                : AppTheme.primary)
                                            .withAlpha(89),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isComplete
                                        ? Icons.replay_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isComplete
                                        ? 'Review Again'
                                        : (widget.todayCount == 0
                                              ? 'Start Review'
                                              : 'Continue'),
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Circular progress ring
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (_, __) => _CircularProgress(
                        progress: _progressAnimation.value,
                        isComplete: isComplete,
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

class _CircularProgress extends StatelessWidget {
  final double progress;
  final bool isComplete;

  const _CircularProgress({required this.progress, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, isComplete: isComplete),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isComplete ? AppTheme.success : AppTheme.primaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isComplete;

  _RingPainter({required this.progress, required this.isComplete});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;
    final trackPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: isComplete
            ? [AppTheme.success, const Color(0xFF059669)]
            : [AppTheme.primaryLight, AppTheme.secondary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isComplete != isComplete;
}
