import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../data/services/vocabulary_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import './widgets/home_due_words_widget.dart';
import './widgets/home_goal_card_widget.dart';
import './widgets/home_header_widget.dart';
import './widgets/home_stats_row_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _todayCount = 0;
  int _streak = 0;
  int _learnedCount = 0;
  double _accuracy = 0;
  bool _isLoading = true;
  bool _isAdmin = false;

  String? _selectedDifficulty;
  String? _selectedCategory;
  List<String> _categories = [];

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    _loadData();
  }

  Future<void> _loadData() async {
    await VocabularyService.ensureUserProfile();
    final results = await Future.wait([
      VocabularyService.getTodayReviewCount(),
      VocabularyService.getStreak(),
      VocabularyService.getLearnedCount(),
      VocabularyService.getTodayAccuracy(),
      VocabularyService.isCurrentUserAdmin(),
      VocabularyService.getCategories(),
    ]);
    if (!mounted) return;
    setState(() {
      _todayCount = results[0] as int;
      _streak = results[1] as int;
      _learnedCount = results[2] as int;
      _accuracy = results[3] as double;
      _isAdmin = results[4] as bool;
      _categories = results[5] as List<String>;
      _isLoading = false;
    });
    _entranceController.forward();
  }

  void _applyFilters() {
    VocabularyService.setFilter(
      difficulty: _selectedDifficulty,
      category: _selectedCategory,
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.flashcardScreen,
      (route) => false,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedDifficulty = null;
      _selectedCategory = null;
    });
    VocabularyService.clearFilters();
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
          child: RefreshIndicator(
            color: AppTheme.primaryLight,
            backgroundColor: AppTheme.surfaceVariantDark,
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryLight,
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: isTablet
                          ? _buildTabletLayout()
                          : _buildPhoneLayout(),
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(
        currentIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.flashcardScreen,
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

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: HomeHeaderWidget(
              streak: _streak,
              isAdmin: _isAdmin,
              onAdminTap: () =>
                  Navigator.pushNamed(context, AppRoutes.adminPanel),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildFilterSection(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: HomeGoalCardWidget(
              todayCount: _todayCount,
              dailyGoal: VocabularyService.dailyGoal,
              onStartReview: _applyFilters,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: HomeStatsRowWidget(
              streak: _streak,
              learnedCount: _learnedCount,
              accuracy: _accuracy,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: HomeDueWordsWidget(onSeeAll: _applyFilters),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: HomeHeaderWidget(
                  streak: _streak,
                  isAdmin: _isAdmin,
                  onAdminTap: () =>
                      Navigator.pushNamed(context, AppRoutes.adminPanel),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildFilterSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: HomeGoalCardWidget(
                  todayCount: _todayCount,
                  dailyGoal: VocabularyService.dailyGoal,
                  onStartReview: _applyFilters,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: HomeStatsRowWidget(
                  streak: _streak,
                  learnedCount: _learnedCount,
                  accuracy: _accuracy,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: HomeDueWordsWidget(onSeeAll: _applyFilters),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final hasFilter = _selectedDifficulty != null || _selectedCategory != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.tune_rounded,
              color: AppTheme.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Filtrele',
              style: GoogleFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            if (hasFilter)
              GestureDetector(
                onTap: _clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withAlpha(30),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: AppTheme.error.withAlpha(60)),
                  ),
                  child: Text(
                    'Temizle',
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        // Difficulty filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _difficulties
                .map((d) => _buildDifficultyChip(d))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Category filter chips
        if (_categories.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip(null, 'Tümü'),
                ..._categories.map((c) => _buildCategoryChip(c, c)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDifficultyChip(String level) {
    final isSelected = _selectedDifficulty == level;
    final color = _levelColor(level);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = isSelected ? null : level;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : AppTheme.glassSurface,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? color : AppTheme.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          level,
          style: GoogleFonts.outfit(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? color : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String? value, String label) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondary,
          ),
        ),
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
