import 'package:flutter/material.dart';
import '../models/study_schedule_model.dart';
import '../providers/schedule_service.dart';
import '../services/notification_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _service = ScheduleService();
  final NotificationService _notifService = NotificationService();

  List<StudySchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<StudySchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<StudySchedule> schedulesForDay(int dayOfWeek) =>
      _schedules.where((s) => s.dayOfWeek == dayOfWeek).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  Future<void> fetchSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _schedules = await _service.getSchedules();
      // Re-schedule semua notif lokal
      await _notifService.rescheduleAll(_schedules);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addSchedule(StudySchedule schedule) async {
    try {
      final created = await _service.createSchedule(schedule);
      _schedules.add(created);
      if (created.isActive) {
        await _notifService.scheduleWeeklyNotification(created);
      }
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  Future<Map<String, dynamic>> updateSchedule(int id, StudySchedule schedule) async {
    try {
      final updated = await _service.updateSchedule(id, schedule);
      final idx = _schedules.indexWhere((s) => s.id == id);
      if (idx != -1) _schedules[idx] = updated;
      // Re-schedule notif (cancel lama, buat baru)
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

  Future<Map<String, dynamic>> deleteSchedule(int id) async {
    try {
      await _service.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      await _notifService.cancelScheduleNotification(id);
      notifyListeners();
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

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
      // Rollback UI jika gagal
      notifyListeners();
    }
  }
}
