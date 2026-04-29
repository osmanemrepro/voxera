import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Conditional imports for web compatibility
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart';

const String _prefHour = 'reminder_hour';
const String _prefMinute = 'reminder_minute';
const String _prefEnabled = 'reminder_enabled';

class NotificationService {
  static final NotificationServiceImpl _impl = NotificationServiceImpl();

  static Future<void> initialize() async {
    if (!kIsWeb) {
      await _impl.initialize();
    }
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    return _impl.requestPermission();
  }

  static Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _saveReminderTime(hour, minute, true);
    if (!kIsWeb) {
      await _impl.scheduleDailyReminder(hour, minute);
    }
  }

  static Future<void> cancelReminder() async {
    await _saveReminderEnabled(false);
    if (!kIsWeb) {
      await _impl.cancelReminder();
    }
  }

  static Future<void> _saveReminderTime(
    int hour,
    int minute,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefHour, hour);
    await prefs.setInt(_prefMinute, minute);
    await prefs.setBool(_prefEnabled, enabled);
  }

  static Future<void> _saveReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, enabled);
  }

  static Future<Map<String, dynamic>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_prefHour) ?? 20,
      'minute': prefs.getInt(_prefMinute) ?? 0,
      'enabled': prefs.getBool(_prefEnabled) ?? false,
    };
  }
}