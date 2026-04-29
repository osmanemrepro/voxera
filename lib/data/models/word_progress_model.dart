enum WordStatus { newWord, learning, known, weak }

class WordProgressModel {
  final String wordId;
  WordStatus status;
  int knownCount;
  int unknownCount;
  DateTime? nextReviewDate;
  DateTime? lastReviewedAt;

  WordProgressModel({
    required this.wordId,
    this.status = WordStatus.newWord,
    this.knownCount = 0,
    this.unknownCount = 0,
    this.nextReviewDate,
    this.lastReviewedAt,
  });

  factory WordProgressModel.fromMap(Map<String, dynamic> map) {
    return WordProgressModel(
      wordId: map['word_id'] as String? ?? map['wordId'] as String? ?? '',
      status: _statusFromString(map['status'] as String? ?? 'newWord'),
      knownCount: map['known_count'] as int? ?? map['knownCount'] as int? ?? 0,
      unknownCount:
          map['unknown_count'] as int? ?? map['unknownCount'] as int? ?? 0,
      nextReviewDate: map['next_review_date'] != null
          ? DateTime.tryParse(map['next_review_date'] as String)
          : map['nextReviewDate'] != null
          ? DateTime.tryParse(map['nextReviewDate'] as String)
          : null,
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.tryParse(map['last_reviewed_at'] as String)
          : map['lastReviewedAt'] != null
          ? DateTime.tryParse(map['lastReviewedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'word_id': wordId,
    'status': status.name,
    'known_count': knownCount,
    'unknown_count': unknownCount,
    'next_review_date': nextReviewDate?.toIso8601String(),
    'last_reviewed_at': lastReviewedAt?.toIso8601String(),
  };

  static WordStatus _statusFromString(String v) {
    switch (v) {
      case 'learning':
        return WordStatus.learning;
      case 'known':
        return WordStatus.known;
      case 'weak':
        return WordStatus.weak;
      default:
        return WordStatus.newWord;
    }
  }

  bool get isDueForReview {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }
}
