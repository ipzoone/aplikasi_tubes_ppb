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

  /// Inisialisasi — panggil sekali di main()
  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // --- Local Notifications setup ---
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bisa navigate ke halaman jadwal jika perlu
      },
    );

    // Buat notification channel Android
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

    // --- FCM setup ---
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground FCM handler
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

    // Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle tap dari background — bisa navigate ke schedule
    });
  }

  /// Ambil FCM token device (dikirim ke backend untuk push notif)
  Future<String?> getFcmToken() async {
    return await _fcm.getToken();
  }

  /// Tampilkan notif langsung (saat ini)
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

  /// Jadwalkan notif lokal mingguan untuk satu jadwal belajar
  Future<void> scheduleWeeklyNotification(StudySchedule schedule) async {
    if (!schedule.isActive || schedule.id == null) return;

    final parts = schedule.startTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Cari hari berikutnya yang cocok
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = _nextWeekdayTime(
      weekday: schedule.dayOfWeek, // 1=Senin, sesuai DateTime.weekday
      hour: hour,
      minute: minute,
    );

    // Jika waktu sudah lewat hari ini, set ke minggu depan
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await _localNotif.zonedSchedule(
      schedule.id! + 1000, // offset agar tidak tabrakan dengan notif lain
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // repeat tiap minggu
    );
  }

  /// Batalkan notif untuk jadwal tertentu
  Future<void> cancelScheduleNotification(int scheduleId) async {
    await _localNotif.cancel(scheduleId + 1000);
  }

  /// Batalkan semua notif terjadwal
  Future<void> cancelAllNotifications() async {
    await _localNotif.cancelAll();
  }

  /// Re-schedule semua jadwal aktif (dipanggil saat app buka)
  Future<void> rescheduleAll(List<StudySchedule> schedules) async {
    await cancelAllNotifications();
    for (final schedule in schedules) {
      if (schedule.isActive) {
        await scheduleWeeklyNotification(schedule);
      }
    }
  }

  /// Helper: cari TZDateTime untuk hari-dan-waktu berikutnya
  tz.TZDateTime _nextWeekdayTime({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Maju hari demi hari sampai weekday cocok
    while (candidate.weekday != weekday) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
