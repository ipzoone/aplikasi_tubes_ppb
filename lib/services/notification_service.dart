import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/study_schedule_model.dart';

/// Handle FCM background messages (top-level function, required by Firebase)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main()
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static const _channelId = 'study_schedule_channel';
  static const _channelName = 'Jadwal Belajar';
  static const _channelDesc = 'Notifikasi pengingat jadwal belajar mingguan';

  /// Inisialisasi konfigurasi notifikasi lokal dan Firebase Messaging (FCM).
  /// Panggil fungsi ini sekali saat inisialisasi aplikasi di main.dart.
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // --- Pengaturan Notifikasi Lokal ---
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Membuat channel notifikasi khusus untuk sistem operasi Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Meminta perizinan alarm presisi untuk Android 12 ke atas (API 31+)
    if (Platform.isAndroid) {
      final androidPlugin = _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();
      await androidPlugin?.requestNotificationsPermission();
    }

    // --- Pengaturan Firebase Cloud Messaging (FCM) ---
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handler ketika pesan notifikasi FCM diterima saat aplikasi berada di Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _showImmediateNotification(
          id: message.hashCode,
          title: notification.title ?? 'SkillTrackIt',
          body: notification.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  /// Mengambil token identifikasi FCM unik dari perangkat ini.
  /// Token ini dikirimkan ke server backend untuk keperluan push notification.
  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  /// Menampilkan notifikasi instan langsung saat dipanggil.
  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _localNotif.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Menjadwalkan notifikasi pengingat mingguan berulang berdasarkan jadwal belajar mahasiswa.
  Future<void> scheduleWeeklyNotification(StudySchedule schedule) async {
    if (!schedule.isActive || schedule.id == null) return;

    final parts = schedule.startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final scheduledDate = _nextWeekdayTime(
      weekday: schedule.dayOfWeek,
      hour: hour,
      minute: minute,
    );

    // Konfigurasi mode penjadwalan alarm (exact vs inexact) untuk kompatibilitas Android 12+
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (Platform.isAndroid) {
      final androidPlugin = _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final canScheduleExact = await androidPlugin?.canScheduleExactNotifications();
      if (canScheduleExact == true) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    }

    await _localNotif.zonedSchedule(
      schedule.id! + 1000,
      '⏰ Waktunya Belajar: ${schedule.title}',
      schedule.description != null && schedule.description!.isNotEmpty
          ? schedule.description!
          : 'Jadwal belajar kamu dimulai pukul ${schedule.startTime}',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Fungsi pengujian untuk memicu notifikasi instan dan notifikasi terjadwal 10 detik.
  Future<void> testNotificationIn5Seconds() async {
    // 1. Tampilkan notifikasi instan langsung
    await _localNotif.show(
      9998,
      '✅ Notif Langsung OK',
      'Permission & channel berjalan. Tunggu notif terjadwal dalam 10 detik...',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
    );

    // 2. Jadwalkan notifikasi pengingat 10 detik dari sekarang
    final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (Platform.isAndroid) {
      final androidPlugin = _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final canExact = await androidPlugin?.canScheduleExactNotifications();
      if (canExact == true) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    }

    await _localNotif.zonedSchedule(
      9999,
      '⏰ Notif Terjadwal OK',
      'zonedSchedule berjalan! Jadwal mingguan siap aktif.',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Membatalkan antrian alarm/notifikasi tertentu berdasarkan ID jadwal.
  Future<void> cancelScheduleNotification(int scheduleId) async {
    await _localNotif.cancel(scheduleId + 1000);
  }

  /// Membatalkan seluruh antrian notifikasi lokal terjadwal pada perangkat.
  Future<void> cancelAllNotifications() async {
    await _localNotif.cancelAll();
  }

  /// Menjadwalkan ulang semua notifikasi untuk seluruh jadwal belajar yang aktif.
  Future<void> rescheduleAll(List<StudySchedule> schedules) async {
    await cancelAllNotifications();
    for (final schedule in schedules) {
      if (schedule.isActive) {
        await scheduleWeeklyNotification(schedule);
      }
    }
  }

  /// Mengkalkulasi pencarian waktu di masa depan yang sesuai dengan hari dan jam target.
  tz.TZDateTime _nextWeekdayTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);

    // Mulai penentuan dari hari ini di jam yang ditentukan
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Perulangan hari untuk mencocokkan target hari dalam seminggu (maksimal 7 hari)
    for (int i = 0; i < 7; i++) {
      if (candidate.weekday == weekday && candidate.isAfter(now)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }
}
