import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  // --- 1. JADWALKAN TAGIHAN SPESIFIK ---
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    final scheduledDate = DateTime(date.year, date.month, date.day, 23, 0);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'bills_channel',
        'Pengingat Tagihan',
        channelDescription: 'Notifikasi untuk tagihan jatuh tempo',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      await _plugin.show(
        id,
        'Jatuh Tempo: $title',
        'Tagihan ini sudah jatuh tempo pada ${date.day}/${date.month}. Segera bayar',
        notificationDetails,
      ); 
    } else {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> scheduleDailyNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Pengingat Harian',
      channelDescription: 'Pengingat Harian',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      999,
      'Cek Tagihan Anda',
      'Jangan lupa cek aplikasi untuk tagihan yang belum lunas.',
      _nextInstanceOfNineAM(),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfNineAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 23);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> showInstantNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'bills_channel',
      'Pengingat Tagihan',
      channelDescription: 'Notifikasi untuk tagihan jatuh tempo',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _plugin.show(
      888, 
      'Test Notifikasi', 
      'Sistem notifikasi aplikasi berfungsi dengan baik!', 
      details,
    );
  }
}