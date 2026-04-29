import 'package:flutter/material.dart';

import '../presentation/flashcard_screen/flashcard_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/stats_screen/stats_screen.dart';
import '../presentation/reminder_settings_screen/reminder_settings_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/profile_setup_screen/profile_setup_screen.dart';
import '../presentation/admin_panel/admin_panel_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String profileSetupScreen = '/profile-setup-screen';
  static const String homeScreen = '/home-screen';
  static const String flashcardScreen = '/flashcard-screen';
  static const String statsScreen = '/stats-screen';
  static const String reminderSettings = '/reminder-settings';
  static const String adminPanel = '/admin-panel';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    loginScreen: (context) => const LoginScreen(),
    profileSetupScreen: (context) => const ProfileSetupScreen(),
    homeScreen: (context) => const HomeScreen(),
    flashcardScreen: (context) => const FlashcardScreen(),
    statsScreen: (context) => const StatsScreen(),
    reminderSettings: (context) => const ReminderSettingsScreen(),
    adminPanel: (context) => const AdminPanelScreen(),
  };
}
