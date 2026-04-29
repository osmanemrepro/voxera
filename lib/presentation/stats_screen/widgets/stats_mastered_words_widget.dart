import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../data/services/vocabulary_service.dart';
import '../../../data/models/word_model.dart';
import '../../../data/models/word_progress_model.dart';

class StatsMasteredWordsWidget extends StatefulWidget {
  const StatsMasteredWordsWidget({super.key});

  @override
  State<StatsMasteredWordsWidget> createState() =>
      _StatsMasteredWordsWidgetState();
}

class _StatsMasteredWordsWidgetState extends State<StatsMasteredWordsWidget> {
  List<WordModel> _masteredWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMastered();
  }

  Future<void> _loadMastered() async {
    final progress = await VocabularyService.getProgress();
    final masteredIds = progress.entries
        .where((e) => e.value.status == WordStatus.known)
        .map((e) => e.key)
        .toSet();
    final allWords = await VocabularyService.getAllWords();
    final mastered = allWords
        .where((w) => masteredIds.contains(w.id))
        .take(6)
        .toList();
    if (!mounted) return;
    setState(() {
      _masteredWords = mastered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.success,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mastered Words',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Reviewed 3+ times correctly',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.success.withAlpha(64)),
                    ),
                    child: Text(
                      '${_masteredWords.length}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                )
              else if (_masteredWords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withAlpha(38)),
                  ),
                  child: Row(
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Master words by reviewing them 3+ times.',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _masteredWords
                      .map((word) => _MasteredChip(word: word))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteredChip extends StatelessWidget {
  final WordModel word;

  const _MasteredChip({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppTheme.success.withAlpha(64)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.success,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            word.word,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}
