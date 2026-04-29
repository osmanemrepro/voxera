import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../data/services/vocabulary_service.dart';
import '../../../data/models/word_model.dart';

class HomeDueWordsWidget extends StatefulWidget {
  final VoidCallback onSeeAll;

  const HomeDueWordsWidget({super.key, required this.onSeeAll});

  @override
  State<HomeDueWordsWidget> createState() => _HomeDueWordsWidgetState();
}

class _HomeDueWordsWidgetState extends State<HomeDueWordsWidget> {
  List<WordModel> _dueWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDueWords();
  }

  Future<void> _loadDueWords() async {
    final words = await VocabularyService.getDueWords();
    if (!mounted) return;
    setState(() {
      _dueWords = words.take(4).toList();
      _isLoading = false;
    });
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return AppTheme.success;
      case 'intermediate':
        return AppTheme.secondary;
      case 'advanced':
        return AppTheme.warning;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Up Next',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: widget.onSeeAll,
              child: Text(
                'Start all →',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          Column(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.glassSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          )
        else if (_dueWords.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.success.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All caught up!',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.success,
                            ),
                          ),
                          Text(
                            'No words due for review right now.',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(_dueWords.length, (index) {
            final word = _dueWords[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + index * 80),
              curve: Curves.easeOutCubic,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.glassSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(38),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                word.word[0].toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.word,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  word.phonetic,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _difficultyColor(
                                word.difficulty,
                              ).withAlpha(38),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              word.difficulty,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _difficultyColor(word.difficulty),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
