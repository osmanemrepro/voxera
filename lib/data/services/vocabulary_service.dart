import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/word_model.dart';
import '../models/word_progress_model.dart';

class VocabularyService {
  static const String _streakKey = 'daily_streak';
  static const String _lastStudyDateKey = 'last_study_date';
  static const String _dailySessionKey = 'daily_session';
  static const int dailyGoal = 20;

  static SupabaseClient get _client => Supabase.instance.client;
  static String? get _userId => _client.auth.currentUser?.id;

  // Cache
  static List<WordModel>? _cachedWords;
  static Map<String, WordProgressModel>? _progressCache;
  static String? _filterDifficulty;
  static String? _filterCategory;

  // ─── Filter Management ───────────────────────────────────────────────────

  static String? get currentDifficulty => _filterDifficulty;
  static String? get currentCategory => _filterCategory;

  static void setFilter({String? difficulty, String? category}) {
    _filterDifficulty = difficulty;
    _filterCategory = category;
    _cachedWords = null; // Invalidate cache
  }

  static void clearFilters() {
    _filterDifficulty = null;
    _filterCategory = null;
    _cachedWords = null;
  }

  // ─── Words from Supabase ─────────────────────────────────────────────────

  static Future<List<WordModel>> getAllWords({
    String? difficulty,
    String? category,
  }) async {
    try {
      var query = _client.from('words').select();

      final diff = difficulty ?? _filterDifficulty;
      final cat = category ?? _filterCategory;

      if (diff != null && diff.isNotEmpty) {
        query = query.eq('difficulty', diff);
      }
      if (cat != null && cat.isNotEmpty) {
        query = query.eq('category', cat);
      }

      final data = await query.order('created_at', ascending: true);
      return (data as List).map((e) => WordModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final data = await _client.from('words').select('category');
      final categories =
          (data as List).map((e) => e['category'] as String).toSet().toList()
            ..sort();
      return categories;
    } catch (e) {
      return [];
    }
  }

  static List<String> get allDifficulties => [
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  // ─── Progress (Supabase) ─────────────────────────────────────────────────

  static Future<Map<String, WordProgressModel>> getProgress() async {
    if (_progressCache != null) return _progressCache!;
    final uid = _userId;
    if (uid == null) return {};

    try {
      final data = await _client
          .from('word_progress')
          .select()
          .eq('user_id', uid);

      _progressCache = {};
      for (final row in (data as List)) {
        final model = WordProgressModel.fromMap(row);
        _progressCache![model.wordId] = model;
      }
      return _progressCache!;
    } catch (e) {
      return {};
    }
  }

  static Future<void> _upsertProgress(WordProgressModel entry) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      await _client.from('word_progress').upsert({
        'user_id': uid,
        ...entry.toMap(),
      }, onConflict: 'user_id,word_id');
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> markKnown(String wordId) async {
    final progress = await getProgress();
    final entry = progress[wordId] ?? WordProgressModel(wordId: wordId);
    entry.knownCount++;
    entry.status = entry.knownCount >= 3
        ? WordStatus.known
        : WordStatus.learning;
    entry.nextReviewDate = DateTime.now().add(const Duration(days: 3));
    entry.lastReviewedAt = DateTime.now();
    if (entry.unknownCount > 2 && entry.knownCount < entry.unknownCount) {
      entry.status = WordStatus.weak;
    }
    progress[wordId] = entry;
    _progressCache = progress;
    await _upsertProgress(entry);
    await _incrementDailySession();
  }

  static Future<void> markUnknown(String wordId) async {
    final progress = await getProgress();
    final entry = progress[wordId] ?? WordProgressModel(wordId: wordId);
    entry.unknownCount++;
    entry.status = entry.unknownCount >= 3
        ? WordStatus.weak
        : WordStatus.learning;
    entry.nextReviewDate = DateTime.now().add(const Duration(days: 1));
    entry.lastReviewedAt = DateTime.now();
    progress[wordId] = entry;
    _progressCache = progress;
    await _upsertProgress(entry);
    await _incrementDailySession();
  }

  static Future<void> _incrementDailySession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final sessionData = prefs.getString(_dailySessionKey);
    Map<String, int> sessions = {};
    if (sessionData != null) {
      sessions = Map<String, int>.from(json.decode(sessionData));
    }
    sessions[today] = (sessions[today] ?? 0) + 1;
    await prefs.setString(_dailySessionKey, json.encode(sessions));
    await _updateStreak();
  }

  static Future<int> getTodayReviewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final sessionData = prefs.getString(_dailySessionKey);
    if (sessionData == null) return 0;
    final sessions = Map<String, int>.from(json.decode(sessionData));
    return sessions[today] ?? 0;
  }

  static Future<List<int>> getLast7DayCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_dailySessionKey);
    Map<String, int> sessions = {};
    if (sessionData != null) {
      sessions = Map<String, int>.from(json.decode(sessionData));
    }
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return sessions[key] ?? 0;
    });
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStudy = prefs.getString(_lastStudyDateKey);
    final today = _todayKey();
    if (lastStudy == today) return;
    final yesterday = () {
      final d = DateTime.now().subtract(const Duration(days: 1));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }();
    int streak = prefs.getInt(_streakKey) ?? 0;
    if (lastStudy == yesterday) {
      streak++;
    } else {
      streak = 1;
    }
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastStudyDateKey, today);
  }

  static Future<List<WordModel>> getDueWords() async {
    final allWords = await getAllWords();
    final progress = await getProgress();
    final due = <WordModel>[];
    for (final word in allWords) {
      final p = progress[word.id];
      if (p == null || p.isDueForReview) {
        due.add(word);
      }
    }
    due.shuffle();
    return due.take(dailyGoal).toList();
  }

  static Future<int> getLearnedCount() async {
    final progress = await getProgress();
    return progress.values.where((p) => p.status == WordStatus.known).length;
  }

  static Future<List<WordModel>> getWeakWords() async {
    final allWords = await getAllWords();
    final progress = await getProgress();
    final weak = <WordModel>[];
    for (final word in allWords) {
      final p = progress[word.id];
      if (p != null && p.status == WordStatus.weak) {
        weak.add(word);
      }
    }
    return weak;
  }

  static Future<double> getTodayAccuracy() async {
    final today = _todayKey();
    final progress = await getProgress();
    int known = 0;
    int total = 0;
    for (final p in progress.values) {
      if (p.lastReviewedAt != null) {
        final reviewDay =
            '${p.lastReviewedAt!.year}-${p.lastReviewedAt!.month.toString().padLeft(2, '0')}-${p.lastReviewedAt!.day.toString().padLeft(2, '0')}';
        if (reviewDay == today) {
          total++;
          if (p.status == WordStatus.known || p.status == WordStatus.learning) {
            known++;
          }
        }
      }
    }
    if (total == 0) return 0;
    return known / total;
  }

  // ─── Admin: Word CRUD ─────────────────────────────────────────────────────

  static Future<bool> addWord(WordModel word) async {
    try {
      await _client.from('words').insert({
        'word': word.word,
        'phonetic': word.phonetic,
        'meaning': word.meaning,
        'example': word.example,
        'category': word.category,
        'difficulty': word.difficulty,
        'created_by': _userId,
      });
      _cachedWords = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateWord(WordModel word) async {
    try {
      await _client
          .from('words')
          .update({
            'word': word.word,
            'phonetic': word.phonetic,
            'meaning': word.meaning,
            'example': word.example,
            'category': word.category,
            'difficulty': word.difficulty,
          })
          .eq('id', word.id);
      _cachedWords = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteWord(String wordId) async {
    try {
      await _client.from('words').delete().eq('id', wordId);
      _cachedWords = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Admin Check ──────────────────────────────────────────────────────────

  static Future<bool> isCurrentUserAdmin() async {
    final uid = _userId;
    if (uid == null) return false;
    try {
      final data = await _client
          .from('user_profiles')
          .select('is_admin')
          .eq('id', uid)
          .maybeSingle();
      return data?['is_admin'] == true;
    } catch (e) {
      return false;
    }
  }

  // ─── Ensure user profile exists ──────────────────────────────────────────

  static Future<void> ensureUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      final existing = await _client
          .from('user_profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      if (existing == null) {
        await _client.from('user_profiles').upsert({
          'id': user.id,
          'email': user.email ?? '',
          'full_name':
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              '',
          'avatar_url': user.userMetadata?['avatar_url'] ?? '',
          'is_admin': user.email == 'osmanemreyaygin0@gmail.com',
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  static void invalidateCache() {
    _cachedWords = null;
    _progressCache = null;
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
