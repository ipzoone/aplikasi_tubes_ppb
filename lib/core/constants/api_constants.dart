class ApiConstants {
  // Gunakan 10.0.2.2 jika pake emulator Android, atau 127.0.0.1 jika pake web/windows
  // Pastikan diakhiri dengan / agar Dio BaseOptions bekerja dengan benar
  static const String baseUrl = 'http://192.168.137.1:8000/api/';
  
  // Endpoint
  static const String skills = 'skills';
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String me = 'me';
  static const String googleLogin = 'login/google';
  static const String schedules = 'schedules';
}
