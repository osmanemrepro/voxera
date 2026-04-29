import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServiceImpl {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 42;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Set the local timezone so scheduled times match device local time
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (_) {
      // Fallback: keep UTC if timezone lookup fails
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    // Android 13+ notification + exact alarm permissions
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
      final granted = await androidImpl.areNotificationsEnabled();
      return granted ?? false;
    }

    // iOS permission
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await _plugin.cancel(_dailyReminderId);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reminder_channel',
          'Günlük Hatırlatıcı',
          channelDescription: 'Günlük 20 kelime hedefi için hatırlatıcı',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // flutter_local_notifications v18: fully named parameters,
    // uiLocalNotificationDateInterpretation removed
    await _plugin.zonedSchedule(
      _dailyReminderId,
      '🎯 Günlük Hedefin Seni Bekliyor!',
      'Bugün henüz 20 kelime hedefini tamamlamadın. Hadi başla!',
      _nextInstanceOf(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}