import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/word_model.dart';
import '../../data/services/vocabulary_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import './widgets/stats_chart_widget.dart';
import './widgets/stats_kpi_row_widget.dart';
import './widgets/stats_mastered_words_widget.dart';
import './widgets/stats_weak_words_widget.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  int _learnedCount = 0;
  int _streak = 0;
  double _accuracy = 0;
  List<int> _last7Days = List.filled(7, 0);
  List<WordModel> _weakWords = [];
  bool _isLoading = true;
  int _totalWords = 0;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _loadStats();
  }

  Future<void> _loadStats() async {
    final results = await Future.wait([
      VocabularyService.getLearnedCount(),
      VocabularyService.getStreak(),
      VocabularyService.getTodayAccuracy(),
      VocabularyService.getLast7DayCounts(),
      VocabularyService.getWeakWords(),
      VocabularyService.getAllWords(),
    ]);
    if (!mounted) return;
    setState(() {
      _learnedCount = results[0] as int;
      _streak = results[1] as int;
      _accuracy = results[2] as double;
      _last7Days = results[3] as List<int>;
      _weakWords = results[4] as List<WordModel>;
      _totalWords = (results[5] as List<WordModel>).length;
      _isLoading = false;
    });
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryLight,
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: RefreshIndicator(
                          color: AppTheme.primaryLight,
                          backgroundColor: AppTheme.surfaceVariantDark,
                          onRefresh: _loadStats,
                          child: isTablet
                              ? _buildTabletLayout()
                              : _buildPhoneLayout(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(
        currentIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeScreen,
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.flashcardScreen,
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Progress',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Speak. Learn. Beyond.',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$_streak day${_streak != 1 ? 's' : ''}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StatsKpiRowWidget(
              learnedCount: _learnedCount,
              streak: _streak,
              accuracy: _accuracy,
              totalWords: _totalWords,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StatsChartWidget(last7Days: _last7Days),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StatsWeakWordsWidget(weakWords: _weakWords),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: StatsMasteredWordsWidget(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: StatsKpiRowWidget(
                  learnedCount: _learnedCount,
                  streak: _streak,
                  accuracy: _accuracy,
                  totalWords: _totalWords,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: StatsChartWidget(last7Days: _last7Days),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: StatsWeakWordsWidget(weakWords: _weakWords),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: StatsMasteredWordsWidget(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
