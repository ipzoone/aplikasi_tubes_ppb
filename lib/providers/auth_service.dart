import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // Simpan data user ke SharedPreferences
  Future<void> _saveSession(String token, String name, String email, [String? avatar]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    if (avatar != null) {
      await prefs.setString('user_avatar', avatar);
    } else {
      await prefs.remove('user_avatar');
    }
  }

  // Hapus data user dari SharedPreferences (Logout)
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_avatar');
  }

  // Mengambil token yang disimpan
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  // Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Fungsi Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 201) {
        final data = response.data;
        // Sesi sengaja tidak disimpan di sini agar user harus masuk secara manual lewat LoginPage
        return {'success': true, 'message': data['message'] ?? 'Registrasi berhasil!'};
      }
      return {'success': false, 'message': 'Registrasi gagal!'};
    } on DioException catch (e) {
      String errMsg = 'Terjadi kesalahan jaringan';
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          // Mengambil error validation dari Laravel
          Map errors = e.response?.data['errors'];
          errMsg = errors.values.map((val) => (val as List).join(', ')).join('\n');
        } else {
          errMsg = e.response?.data['message'] ?? errMsg;
        }
      }
      return {'success': false, 'message': errMsg};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Fungsi Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final userData = data['user'];
        
        await _saveSession(token, userData['name'], userData['email'], userData['google_avatar']);
        
        return {'success': true, 'message': data['message'] ?? 'Login berhasil!'};
      }
      return {'success': false, 'message': 'Login gagal!'};
    } on DioException catch (e) {
      String errMsg = 'Terjadi kesalahan jaringan';
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          Map errors = e.response?.data['errors'];
          errMsg = errors.values.map((val) => (val as List).join(', ')).join('\n');
        } else {
          errMsg = e.response?.data['message'] ?? errMsg;
        }
      }
      return {'success': false, 'message': errMsg};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Fungsi Login dengan Google
  Future<Map<String, dynamic>> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _dio.post(
        ApiConstants.googleLogin,
        data: {
          'id_token': idToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final userData = data['user'];

        await _saveSession(token, userData['name'], userData['email'], userData['google_avatar']);

        return {'success': true, 'message': data['message'] ?? 'Login Google berhasil!'};
      }
      return {'success': false, 'message': 'Login Google gagal!'};
    } on DioException catch (e) {
      String errMsg = 'Terjadi kesalahan jaringan';
      if (e.response != null && e.response?.data != null) {
        if (e.response?.data['errors'] != null) {
          Map errors = e.response?.data['errors'];
          errMsg = errors.values.map((val) => (val as List).join(', ')).join('\n');
        } else {
          errMsg = e.response?.data['message'] ?? errMsg;
        }
      } else {
        print('DioException detail: ${e.type} - ${e.message} - ${e.error}');
        errMsg = 'Kesalahan Koneksi: ${e.message}';
      }
      return {'success': false, 'message': errMsg};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Fungsi Logout

  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await _dio.post(
          ApiConstants.logout,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
    } catch (e) {
      // Abaikan jika request API logout gagal, kita tetap hapus data lokal
    } finally {
      await _clearSession();
    }
    return {'success': true, 'message': 'Logout berhasil!'};
  }
}
