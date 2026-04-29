import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../data/models/word_model.dart';
import '../../data/services/vocabulary_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_navigation.dart';
import './widgets/flashcard_action_buttons_widget.dart';
import './widgets/flashcard_card_widget.dart';
import './widgets/flashcard_complete_widget.dart';
import './widgets/flashcard_progress_widget.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  List<WordModel> _words = [];
  int _currentIndex = 0;
  int _reviewedToday = 0;
  bool _isFlipped = false;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  bool _isSpeaking = false;

  late FlutterTts _flutterTts;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _swipeFadeAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  double _swipeOpacity = 1.0;
  Color? _swipeTintColor;

  @override
  void initState() {
    super.initState();
    _initTts();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeOutCubic),
        );
    _swipeFadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _loadWords();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }
    HapticFeedback.lightImpact();
    await _flutterTts.speak(text);
  }

  Future<void> _loadWords() async {
    final words = await VocabularyService.getDueWords();
    final todayCount = await VocabularyService.getTodayReviewCount();
    if (!mounted) return;
    setState(() {
      _words = words;
      _reviewedToday = todayCount;
      _isLoading = false;
      _isSessionComplete = words.isEmpty;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _flipController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  Future<void> _markKnown() async {
    HapticFeedback.mediumImpact();
    if (_currentIndex >= _words.length) return;
    await VocabularyService.markKnown(_words[_currentIndex].id);
    _advanceCard();
  }

  Future<void> _markUnknown() async {
    HapticFeedback.heavyImpact();
    if (_currentIndex >= _words.length) return;
    await VocabularyService.markUnknown(_words[_currentIndex].id);
    _advanceCard();
  }

  void _advanceCard() {
    _flutterTts.stop();
    setState(() {
      _reviewedToday++;
      _dragOffset = Offset.zero;
      _swipeOpacity = 1.0;
      _swipeTintColor = null;
      _isSpeaking = false;
    });
    if (_flipController.isCompleted) {
      _flipController.reset();
    }
    setState(() => _isFlipped = false);

    if (_currentIndex + 1 >= _words.length ||
        _reviewedToday >= VocabularyService.dailyGoal) {
      setState(() => _isSessionComplete = true);
    } else {
      setState(() => _currentIndex++);
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += Offset(details.delta.dx, details.delta.dy * 0.3);
      final threshold = 80.0;
      if (_dragOffset.dx > threshold) {
        _swipeTintColor = AppTheme.success;
        _swipeOpacity = 1.0;
      } else if (_dragOffset.dx < -threshold) {
        _swipeTintColor = AppTheme.error;
        _swipeOpacity = 1.0;
      } else {
        _swipeTintColor = null;
        _swipeOpacity = 1.0;
      }
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    final threshold = 100.0;
    if (_dragOffset.dx > threshold) {
      // Swipe right = Known
      setState(() {
        _dragOffset = const Offset(400, -50);
        _swipeOpacity = 0;
      });
      await Future.delayed(const Duration(milliseconds: 250));
      _markKnown();
    } else if (_dragOffset.dx < -threshold) {
      // Swipe left = Unknown
      setState(() {
        _dragOffset = const Offset(-400, -50);
        _swipeOpacity = 0;
      });
      await Future.delayed(const Duration(milliseconds: 250));
      _markUnknown();
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
        _swipeTintColor = null;
        _swipeOpacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryLight,
                  ),
                )
              : _isSessionComplete
              ? FlashcardCompleteWidget(
                  reviewedCount: _reviewedToday,
                  onGoHome: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homeScreen,
                    (route) => false,
                  ),
                  onSeeStats: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.statsScreen,
                    (route) => false,
                  ),
                )
              : _buildCardSession(isTablet),
        ),
      ),
      bottomNavigationBar: _isSessionComplete
          ? null
          : AppNavigation(
              currentIndex: 1,
              onDestinationSelected: (index) {
                if (index == 0) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homeScreen,
                    (route) => false,
                  );
                } else if (index == 2) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.statsScreen,
                    (route) => false,
                  );
                }
              },
            ),
    );
  }

  Widget _buildCardSession(bool isTablet) {
    final currentWord = _words.isNotEmpty && _currentIndex < _words.length
        ? _words[_currentIndex]
        : null;

    if (currentWord == null) {
      return FlashcardCompleteWidget(
        reviewedCount: _reviewedToday,
        onGoHome: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.homeScreen,
          (route) => false,
        ),
        onSeeStats: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.statsScreen,
          (route) => false,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 20,
            8,
            isTablet ? 24 : 20,
            0,
          ),
          child: FlashcardProgressWidget(
            current: _currentIndex + 1,
            total: _words.length,
          ),
        ),
        // Filter info bar
        if (VocabularyService.currentDifficulty != null ||
            VocabularyService.currentCategory != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _buildFilterBar(),
          ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 520 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  onTap: _flipCard,
                  child: AnimatedOpacity(
                    opacity: _swipeOpacity,
                    duration: const Duration(milliseconds: 150),
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Transform.rotate(
                        angle: _dragOffset.dx * 0.003,
                        child: Stack(
                          children: [
                            FlashcardCardWidget(
                              word: currentWord,
                              flipAnimation: _flipAnimation,
                              isFlipped: _isFlipped,
                              swipeTintColor: _swipeTintColor,
                            ),
                            // TTS button overlay
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildTtsButton(currentWord),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 20,
            0,
            isTablet ? 24 : 20,
            16,
          ),
          child: FlashcardActionButtonsWidget(
            onKnown: _markKnown,
            onUnknown: _markUnknown,
            onFlip: _flipCard,
            isFlipped: _isFlipped,
          ),
        ),
        SizedBox(height: isTablet ? 80 : 70),
      ],
    );
  }

  Widget _buildTtsButton(WordModel word) {
    return GestureDetector(
      onTap: () => _speak(word.word),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isSpeaking
              ? AppTheme.primary.withAlpha(200)
              : AppTheme.glassSurface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: _isSpeaking ? AppTheme.primaryLight : AppTheme.glassBorder,
            width: 1,
          ),
          boxShadow: _isSpeaking
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(80),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
          color: _isSpeaking ? Colors.white : AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_list_rounded,
            color: AppTheme.primaryLight,
            size: 14,
          ),
          const SizedBox(width: 6),
          if (VocabularyService.currentDifficulty != null)
            Text(
              VocabularyService.currentDifficulty!,
              style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
          if (VocabularyService.currentDifficulty != null &&
              VocabularyService.currentCategory != null)
            const Text(' · ', style: TextStyle(color: AppTheme.primaryLight)),
          if (VocabularyService.currentCategory != null)
            Text(
              VocabularyService.currentCategory!,
              style: GoogleFonts.outfit(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
        ],
      ),
    );
  }
}
