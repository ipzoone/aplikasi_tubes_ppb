import 'package:flutter/material.dart';
import '../models/study_schedule_model.dart';
import '../providers/schedule_service.dart';
import '../services/notification_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _service = ScheduleService();
  final NotificationService _notifService = NotificationService();

  // Variabel state untuk menyimpan list jadwal, status loading, dan pesan error
  List<StudySchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  // Getter untuk mengakses state secara aman dari UI
  List<StudySchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Mengambil jadwal berdasarkan hari tertentu dan diurutkan berdasarkan jam mulai.
  List<StudySchedule> schedulesForDay(int dayOfWeek) =>
      _schedules.where((s) => s.dayOfWeek == dayOfWeek).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  /// Mengambil daftar semua jadwal belajar secara asynchronous dan mengatur ulang notifikasi alarm.
  Future<void> fetchSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _schedules = await _service.getSchedules();
      // Sinkronisasi ulang semua notifikasi lokal di perangkat berdasarkan jadwal terbaru
      await _notifService.rescheduleAll(_schedules);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan jadwal belajar baru, lalu mengaktifkan notifikasi alarm jika statusnya aktif.
  Future<Map<String, dynamic>> addSchedule(StudySchedule schedule) async {
    try {
      final created = await _service.createSchedule(schedule);
      _schedules.add(created);
      if (created.isActive) {
        // Daftarkan alarm pemberitahuan mingguan di HP
        await _notifService.scheduleWeeklyNotification(created);
      }
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Memperbarui jadwal belajar, lalu menyetel ulang alarm pemberitahuan di perangkat.
  Future<Map<String, dynamic>> updateSchedule(int id, StudySchedule schedule) async {
    try {
      final updated = await _service.updateSchedule(id, schedule);
      final idx = _schedules.indexWhere((s) => s.id == id);
      if (idx != -1) _schedules[idx] = updated;
      
      // Hapus alarm lama, lalu daftarkan alarm baru jika statusnya aktif
      await _notifService.cancelScheduleNotification(id);
      if (updated.isActive) {
        await _notifService.scheduleWeeklyNotification(updated);
      }
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Menghapus jadwal belajar dan membatalkan alarm yang terasosiasi dengannya.
  Future<Map<String, dynamic>> deleteSchedule(int id) async {
    try {
      await _service.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      // Batalkan alarm dari daftar notifikasi sistem
      await _notifService.cancelScheduleNotification(id);
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  /// Mengaktifkan atau menonaktifkan alarm jadwal (on/off toggle) dari switch UI.
  Future<void> toggleSchedule(int id, bool isActive) async {
    try {
      final updated = await _service.toggleSchedule(id, isActive);
      final idx = _schedules.indexWhere((s) => s.id == id);
      if (idx != -1) _schedules[idx] = updated;
      
      if (isActive) {
        await _notifService.scheduleWeeklyNotification(updated);
      } else {
        await _notifService.cancelScheduleNotification(id);
      }
      notifyListeners();
    } catch (e) {
      // Rollback tampilan UI jika request API mengalami kegagalan
      notifyListeners();
    }
  }
}

