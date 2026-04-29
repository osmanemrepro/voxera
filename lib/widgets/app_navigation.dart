import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) {
      return _TabletRail(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
      );
    }
    return _LiquidGlassNavBar(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}

class _LiquidGlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  State<_LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<_LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pillController;
  late Animation<double> _pillAnimation;
  int _previousIndex = 0;

  final List<({IconData icon, IconData activeIcon, String label})>
  _destinations = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.style_outlined,
      activeIcon: Icons.style_rounded,
      label: 'Cards',
    ),
    (
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pillAnimation = CurvedAnimation(
      parent: _pillController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(_LiquidGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _pillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: AppTheme.glassSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.glassBorder, width: 1),
            ),
            child: Row(
              children: List.generate(_destinations.length, (index) {
                final dest = _destinations[index];
                final isActive = index == widget.currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDestinationSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primary.withAlpha(64)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isActive ? dest.activeIcon : dest.icon,
                              key: ValueKey(isActive),
                              color: isActive
                                  ? AppTheme.primaryLight
                                  : AppTheme.textMuted,
                              size: isActive ? 24 : 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? AppTheme.primaryLight
                                  : AppTheme.textMuted,
                            ),
                            child: Text(dest.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabletRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const _TabletRail({
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppTheme.surfaceDark,
      indicatorColor: AppTheme.primary.withAlpha(64),
      selectedIconTheme: const IconThemeData(
        color: AppTheme.primaryLight,
        size: 24,
      ),
      unselectedIconTheme: const IconThemeData(
        color: AppTheme.textMuted,
        size: 22,
      ),
      selectedLabelTextStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryLight,
      ),
      unselectedLabelTextStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppTheme.textMuted,
      ),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.style_outlined),
          selectedIcon: Icon(Icons.style_rounded),
          label: Text('Cards'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: Text('Stats'),
        ),
      ],
    );
  }
}

/// Main scaffold wrapper with navigation
class VoxeraScaffold extends StatefulWidget {
  final int initialIndex;

  const VoxeraScaffold({super.key, this.initialIndex = 0});

  @override
  State<VoxeraScaffold> createState() => _VoxeraScaffoldState();
}

class _VoxeraScaffoldState extends State<VoxeraScaffold> {
  late int _currentIndex;

  final List<String> _routes = [
    AppRoutes.homeScreen,
    AppRoutes.flashcardScreen,
    AppRoutes.statsScreen,
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigate(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    Navigator.pushNamedAndRemoveUntil(
      context,
      _routes[index],
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: AppNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _navigate,
      ),
      body: const SizedBox.shrink(),
    );
  }
}
