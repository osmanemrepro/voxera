import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/word_model.dart';

class StatsWeakWordsWidget extends StatelessWidget {
  final List<WordModel> weakWords;

  const StatsWeakWordsWidget({super.key, required this.weakWords});

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
                      color: AppTheme.errorSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.error,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weak Words',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Need more practice',
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
                      color: AppTheme.errorSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.error.withAlpha(64)),
                    ),
                    child: Text(
                      '${weakWords.length}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (weakWords.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success.withAlpha(51)),
                  ),
                  child: Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No weak words yet! Keep reviewing.',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...weakWords.take(8).map((word) => _WeakWordItem(word: word)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeakWordItem extends StatelessWidget {
  final WordModel word;

  const _WeakWordItem({required this.word});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withAlpha(38)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  word.word[0],
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    word.meaning,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.error.withAlpha(38),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '⚡ Weak',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
