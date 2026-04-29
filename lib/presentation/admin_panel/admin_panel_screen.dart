import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/word_model.dart';
import '../../data/services/vocabulary_service.dart';
import '../../theme/app_theme.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<WordModel> _words = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _filterDifficulty;

  static const List<String> _difficulties = [
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    final words = await VocabularyService.getAllWords(
      difficulty: _filterDifficulty,
    );
    if (!mounted) return;
    setState(() {
      _words = words;
      _isLoading = false;
    });
  }

  List<WordModel> get _filteredWords {
    if (_searchQuery.isEmpty) return _words;
    final q = _searchQuery.toLowerCase();
    return _words
        .where(
          (w) =>
              w.word.toLowerCase().contains(q) ||
              w.meaning.toLowerCase().contains(q) ||
              w.category.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _deleteWord(WordModel word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Kelimeyi Sil',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${word.word}" kelimesini silmek istediğinize emin misiniz?',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'İptal',
              style: GoogleFonts.outfit(color: AppTheme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Sil', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await VocabularyService.deleteWord(word.id);
      if (success && mounted) {
        _loadWords();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${word.word}" silindi.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  void _openWordForm({WordModel? word}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WordFormSheet(
        word: word,
        onSaved: () {
          Navigator.pop(ctx);
          _loadWords();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchAndFilter(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryLight,
                        ),
                      )
                    : _filteredWords.isEmpty
                    ? _buildEmptyState()
                    : _buildWordList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWordForm(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Kelime Ekle',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.glassSurface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Paneli',
                  style: GoogleFonts.outfit(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${_words.length} kelime',
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Admin',
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.outfit(
                color: AppTheme.textPrimary,
                fontSize: 12.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Kelime ara...',
                hintStyle: GoogleFonts.outfit(
                  color: AppTheme.textMuted,
                  fontSize: 12.sp,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Tümü'),
                ..._difficulties.map((d) => _buildFilterChip(d, d)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _filterDifficulty == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filterDifficulty = value);
        _loadWords();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withAlpha(50)
              : AppTheme.glassSurface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildWordList() {
    return RefreshIndicator(
      color: AppTheme.primaryLight,
      backgroundColor: AppTheme.surfaceVariantDark,
      onRefresh: _loadWords,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: _filteredWords.length,
        itemBuilder: (ctx, i) => _buildWordCard(_filteredWords[i]),
      ),
    );
  }

  Widget _buildWordCard(WordModel word) {
    final levelColor = _levelColor(word.difficulty);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: levelColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: levelColor.withAlpha(80)),
              ),
              child: Center(
                child: Text(
                  word.difficulty,
                  style: GoogleFonts.outfit(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: levelColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        word.word,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (word.phonetic.isNotEmpty)
                        Text(
                          word.phonetic,
                          style: GoogleFonts.outfit(
                            fontSize: 9.sp,
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    word.meaning,
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      word.category,
                      style: GoogleFonts.outfit(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () => _openWordForm(word: word),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppTheme.secondary,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _deleteWord(word),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.error.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: AppTheme.error,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.library_books_outlined,
            color: AppTheme.textMuted,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Kelime bulunamadı',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Yeni kelime eklemek için + butonuna basın',
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFF10B981);
      case 'A2':
        return const Color(0xFF34D399);
      case 'B1':
        return const Color(0xFF3B82F6);
      case 'B2':
        return const Color(0xFF6366F1);
      case 'C1':
        return const Color(0xFFF59E0B);
      case 'C2':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.primaryLight;
    }
  }
}

// ─── Word Form Bottom Sheet ───────────────────────────────────────────────────

class _WordFormSheet extends StatefulWidget {
  final WordModel? word;
  final VoidCallback onSaved;

  const _WordFormSheet({this.word, required this.onSaved});

  @override
  State<_WordFormSheet> createState() => _WordFormSheetState();
}

class _WordFormSheetState extends State<_WordFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordCtrl;
  late TextEditingController _phoneticCtrl;
  late TextEditingController _meaningCtrl;
  late TextEditingController _exampleCtrl;
  late TextEditingController _categoryCtrl;
  String _selectedDifficulty = 'A1';
  bool _isSaving = false;

  static const List<String> _difficulties = [
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.word?.word ?? '');
    _phoneticCtrl = TextEditingController(text: widget.word?.phonetic ?? '');
    _meaningCtrl = TextEditingController(text: widget.word?.meaning ?? '');
    _exampleCtrl = TextEditingController(text: widget.word?.example ?? '');
    _categoryCtrl = TextEditingController(
      text: widget.word?.category ?? 'General',
    );
    _selectedDifficulty = widget.word?.difficulty ?? 'A1';
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _phoneticCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final wordModel = WordModel(
      id: widget.word?.id ?? '',
      word: _wordCtrl.text.trim(),
      phonetic: _phoneticCtrl.text.trim(),
      meaning: _meaningCtrl.text.trim(),
      example: _exampleCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty
          ? 'General'
          : _categoryCtrl.text.trim(),
      difficulty: _selectedDifficulty,
    );

    bool success;
    if (widget.word == null) {
      success = await VocabularyService.addWord(wordModel);
    } else {
      success = await VocabularyService.updateWord(wordModel);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      widget.onSaved();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.glassBorder,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.word == null ? 'Yeni Kelime Ekle' : 'Kelimeyi Düzenle',
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildField(
                _wordCtrl,
                'Kelime *',
                Icons.text_fields_rounded,
                required: true,
              ),
              const SizedBox(height: 10),
              _buildField(
                _phoneticCtrl,
                'Fonetik (örn: /ˈæp.əl/)',
                Icons.record_voice_over_rounded,
              ),
              const SizedBox(height: 10),
              _buildField(
                _meaningCtrl,
                'Anlam (Türkçe) *',
                Icons.translate_rounded,
                required: true,
              ),
              const SizedBox(height: 10),
              _buildField(
                _exampleCtrl,
                'Örnek cümle',
                Icons.format_quote_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              _buildField(
                _categoryCtrl,
                'Kategori (örn: Food, Travel)',
                Icons.category_rounded,
              ),
              const SizedBox(height: 14),
              Text(
                'Seviye',
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _difficulties.map((d) {
                  final isSelected = _selectedDifficulty == d;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDifficulty = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withAlpha(60)
                            : AppTheme.glassSurface,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.glassBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        d,
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.word == null ? 'Kelime Ekle' : 'Güncelle',
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: GoogleFonts.outfit(color: AppTheme.textPrimary, fontSize: 12.sp),
        validator: required
            ? (v) =>
                  (v == null || v.trim().isEmpty) ? 'Bu alan zorunludur' : null
            : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            color: AppTheme.textMuted,
            fontSize: 11.sp,
          ),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
