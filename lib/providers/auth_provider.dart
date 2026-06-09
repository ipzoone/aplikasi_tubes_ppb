import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Menyimpan token akses API dan data profil pengguna secara lokal dalam state
  String? _token;
  String? _userName;
  String? _userEmail;
  String? _userAvatar;

  // Getter untuk validasi status login dan pengambilan detail akun pengguna
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String get userName => _userName ?? 'Mahasiswa IT';
  String get userEmail => _userEmail ?? '';
  String? get userAvatar => _userAvatar;

  AuthProvider() {
    _loadSession();
  }

  /// Memuat data sesi login yang tersimpan di memori persisten SharedPreferences.
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userAvatar = prefs.getString('user_avatar');
    notifyListeners();
  }

  /// Memperbarui nama pengguna di penyimpanan lokal dan memberi tahu UI.
  Future<void> updateLocalName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    _userName = newName;
    notifyListeners();
  }

  /// Melakukan login kredensial lokal (email & password) ke backend API.
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    if (result['success'] == true) {
      await _loadSession(); // Perbarui status session terbaru
    }
    notifyListeners();
    return result;
  }

  /// Melakukan otentikasi login menggunakan akun Google via Firebase.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Memulai proses sign-in Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in dibatalkan oleh pengguna'};
      }

      // Mendapatkan detail otentikasi dari akun Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'Gagal mendapatkan ID Token Google'};
      }

      // Mengirimkan ID Token Google ke backend server API kita
      final result = await _authService.loginWithGoogle(idToken: idToken);
      if (result['success'] == true) {
        await _loadSession();
      }
      notifyListeners();
      return result;
    } catch (error) {
      return {'success': false, 'message': 'Error Google Sign In: $error'};
    }
  }

  /// Mendaftarkan akun baru ke backend API (tidak login secara otomatis).
  Future<Map<String, dynamic>> register({required String name, required String email, required String password, required String passwordConfirmation}) async {
    final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation);
    return result;
  }

  /// Mengeluarkan pengguna (logout) dan membersihkan data sesi lokal & Google Sign-In.
  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _authService.logout();
    _token = null;
    _userName = null;
    _userEmail = null;
    _userAvatar = null;
    notifyListeners();
  }
}

}
