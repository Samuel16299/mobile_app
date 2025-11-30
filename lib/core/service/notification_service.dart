import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Inisialisasi plugin
  Future<void> init() async {
    tz.initializeTimeZones(); // Inisialisasi timezone data

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

  // Jadwalkan Notifikasi
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    // Set waktu notifikasi ke jam 09:00 pagi pada tanggal jatuh tempo
    final scheduledDate = DateTime(date.year, date.month, date.day, 9, 0);
    
    // Jangan jadwalkan jika waktu sudah lewat
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bills_channel', // Id Channel
          'Pengingat Tagihan', // Nama Channel
          channelDescription: 'Notifikasi untuk tagihan jatuh tempo',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
      'Sistem notifikasi aplikasi berfungsi dengan baik! 🔔', 
      details,
    );
  }
}