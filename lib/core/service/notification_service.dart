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
        title,
        body,
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

  // Batalkan Notifikasi
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
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
      888, // ID unik sembarang untuk test
      'Test Notifikasi', 
      'Sistem notifikasi aplikasi berfungsi dengan baik!', 
      details,
    );
  }
}