import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FlashcardActionButtonsWidget extends StatelessWidget {
  final VoidCallback onKnown;
  final VoidCallback onUnknown;
  final VoidCallback onFlip;
  final bool isFlipped;

  const FlashcardActionButtonsWidget({
    super.key,
    required this.onKnown,
    required this.onUnknown,
    required this.onFlip,
    required this.isFlipped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Don't Know
          Expanded(
            child: _ActionButton(
              onTap: onUnknown,
              icon: Icons.close_rounded,
              label: "Don't Know",
              color: AppTheme.error,
              surfaceColor: AppTheme.errorSurface,
            ),
          ),
          const SizedBox(width: 12),
          // Flip
          _FlipButton(onTap: onFlip, isFlipped: isFlipped),
          const SizedBox(width: 12),
          // I Know
          Expanded(
            child: _ActionButton(
              onTap: onKnown,
              icon: Icons.check_rounded,
              label: 'I Know',
              color: AppTheme.success,
              surfaceColor: AppTheme.successSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final Color surfaceColor;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.surfaceColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.color.withAlpha(77), width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(38),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 26),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlipButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isFlipped;

  const _FlipButton({required this.onTap, required this.isFlipped});

  @override
  State<_FlipButton> createState() => _FlipButtonState();
}

class _FlipButtonState extends State<_FlipButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotController;
  late Animation<double> _rotAnimation;

  @override
  void initState() {
    super.initState();
    _rotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_FlipButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped != widget.isFlipped) {
      if (widget.isFlipped) {
        _rotController.forward();
      } else {
        _rotController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _rotAnimation,
        builder: (_, child) => Transform.rotate(
          angle: _rotAnimation.value * 3.14159,
          child: child,
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(102),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.flip_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
