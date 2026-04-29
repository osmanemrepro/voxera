import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/word_model.dart';

class FlashcardCardWidget extends StatelessWidget {
  final WordModel word;
  final Animation<double> flipAnimation;
  final bool isFlipped;
  final Color? swipeTintColor;

  const FlashcardCardWidget({
    super.key,
    required this.word,
    required this.flipAnimation,
    required this.isFlipped,
    this.swipeTintColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final angle = flipAnimation.value * math.pi;
        final isShowingBack = angle > math.pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isShowingBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _CardBack(word: word, swipeTintColor: swipeTintColor),
                )
              : _CardFront(word: word, swipeTintColor: swipeTintColor),
        );
      },
    );
  }
}

class _CardFront extends StatelessWidget {
  final WordModel word;
  final Color? swipeTintColor;

  const _CardFront({required this.word, this.swipeTintColor});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'verb':
        return AppTheme.secondary;
      case 'noun':
        return AppTheme.warning;
      case 'adjective':
        return AppTheme.primaryLight;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: screenHeight * 0.52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: swipeTintColor != null
                  ? [
                      swipeTintColor!.withAlpha(64),
                      swipeTintColor!.withAlpha(26),
                    ]
                  : const [Color(0xFF2A1B5E), Color(0xFF1A2A6C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: swipeTintColor != null
                  ? swipeTintColor!.withAlpha(102)
                  : AppTheme.glassBorderBright,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (swipeTintColor ?? AppTheme.primary).withAlpha(64),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative orbs
              Positioned(
                right: -40,
                bottom: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withAlpha(26),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.secondary.withAlpha(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _categoryColor(word.category).withAlpha(38),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _categoryColor(
                                word.category,
                              ).withAlpha(77),
                            ),
                          ),
                          child: Text(
                            word.category.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _categoryColor(word.category),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.glassSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.touch_app_rounded,
                            color: AppTheme.textMuted,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        word.word,
                        style: GoogleFonts.outfit(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.phonetic,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: AppTheme.textMuted.withAlpha(128),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to reveal meaning',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textMuted.withAlpha(128),
                            ),
                          ),
                        ],
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

class _CardBack extends StatelessWidget {
  final WordModel word;
  final Color? swipeTintColor;

  const _CardBack({required this.word, this.swipeTintColor});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: screenHeight * 0.52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: swipeTintColor != null
                  ? [
                      swipeTintColor!.withAlpha(64),
                      swipeTintColor!.withAlpha(26),
                    ]
                  : const [Color(0xFF1A2A6C), Color(0xFF2A1B5E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: swipeTintColor != null
                  ? swipeTintColor!.withAlpha(102)
                  : AppTheme.glassBorderBright,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (swipeTintColor ?? AppTheme.secondary).withAlpha(64),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.secondary.withAlpha(77),
                        ),
                      ),
                      child: Text(
                        'TÜRKÇE',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Audio TTS button
                    _AudioButton(word: word.word),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  word.word,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  word.meaning,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 16,
                            color: AppTheme.primaryLight.withAlpha(153),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Example',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight.withAlpha(153),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.example,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text(
                    word.phonetic,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioButton extends StatefulWidget {
  final String word;

  const _AudioButton({required this.word});

  @override
  State<_AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<_AudioButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _playAudio() {
    // TODO: Integrate flutter_tts or similar TTS package for production audio playback
    setState(() => _isPlaying = true);
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isPlaying = false);
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _playAudio,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, child) => Transform.scale(
          scale: _isPlaying ? _pulseAnimation.value : 1.0,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: _isPlaying
                ? const LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
                  )
                : null,
            color: _isPlaying ? null : AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPlaying
                  ? AppTheme.primaryLight.withAlpha(128)
                  : AppTheme.glassBorder,
            ),
            boxShadow: _isPlaying
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(102),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            _isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
            color: _isPlaying ? Colors.white : AppTheme.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
