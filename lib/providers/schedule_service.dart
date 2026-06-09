import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_schedule_model.dart';
import '../core/constants/api_constants.dart';

class ScheduleService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  ScheduleService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('api_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  /// Mengambil daftar semua jadwal belajar dari API.
  /// Menggunakan metode HTTP GET pada endpoint schedules.
  Future<List<StudySchedule>> getSchedules() async {
    try {
      final response = await _dio.get(ApiConstants.schedules);
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((item) => StudySchedule.fromJson(item)).toList();
      }
      throw Exception('Gagal mengambil jadwal dari server');
    } on DioException catch (e) {
      throw Exception('Kesalahan Jaringan/Dio: ${e.message}');
    }
  }

  /// Membuat jadwal belajar baru di database backend.
  /// Menggunakan metode HTTP POST dengan menyertakan payload data jadwal.
  Future<StudySchedule> createSchedule(StudySchedule schedule) async {
    try {
      final response = await _dio.post(
        ApiConstants.schedules,
        data: schedule.toJson(),
      );
      if (response.statusCode == 201) {
        return StudySchedule.fromJson(response.data);
      }
      throw Exception('Gagal membuat jadwal baru');
    } on DioException catch (e) {
      String msg = 'Terjadi kesalahan saat memproses jadwal';
      if (e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          Map errors = e.response?.data['errors'];
          msg = errors.values.map((v) => (v as List).join(', ')).join('\n');
        } else {
          msg = e.response?.data['message'] ?? msg;
        }
      }
      throw Exception(msg);
    }
  }

  /// Memperbarui jadwal belajar yang sudah ada berdasarkan ID jadwal.
  /// Menggunakan metode HTTP PUT pada API endpoint.
  Future<StudySchedule> updateSchedule(int id, StudySchedule schedule) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.schedules}/$id',
        data: {
          ...schedule.toJson(),
          '_method': 'PUT', // standard Laravel REST routing fallback
        },
      );
      if (response.statusCode == 200) {
        return StudySchedule.fromJson(response.data);
      }
      throw Exception('Gagal mengupdate data jadwal');
    } on DioException catch (e) {
      throw Exception('Kesalahan Jaringan/Dio: ${e.message}');
    }
  }

  /// Menghapus jadwal belajar dari database backend berdasarkan ID.
  /// Menggunakan metode HTTP DELETE pada API endpoint.
  Future<void> deleteSchedule(int id) async {
    try {
      await _dio.delete('${ApiConstants.schedules}/$id');
    } on DioException catch (e) {
      throw Exception('Kesalahan Jaringan/Dio: ${e.message}');
    }
  }

  /// Mengaktifkan atau menonaktifkan alarm/notifikasi jadwal belajar.
  /// Menggunakan metode HTTP PATCH pada endpoint toggle.
  Future<StudySchedule> toggleSchedule(int id, bool isActive) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.schedules}/$id/toggle',
        data: {'is_active': isActive},
      );
      if (response.statusCode == 200) {
        return StudySchedule.fromJson(response.data);
      }
      throw Exception('Gagal mengubah status aktif jadwal');
    } on DioException catch (e) {
      throw Exception('Kesalahan Jaringan/Dio: ${e.message}');
    }
  }
}

