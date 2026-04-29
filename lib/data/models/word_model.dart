class WordModel {
  final String id;
  final String word;
  final String phonetic;
  final String meaning;
  final String example;
  final String category;
  final String difficulty;

  const WordModel({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.meaning,
    required this.example,
    required this.category,
    required this.difficulty,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as String,
      word: map['word'] as String,
      phonetic: map['phonetic'] as String? ?? '',
      meaning: map['meaning'] as String,
      example: map['example'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      difficulty: map['difficulty'] as String? ?? 'A1',
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'word': word,
    'phonetic': phonetic,
    'meaning': meaning,
    'example': example,
    'category': category,
    'difficulty': difficulty,
  };
}
