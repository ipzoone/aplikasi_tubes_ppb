import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  String? _token;
  String? _userName;
  String? _userEmail;
  String? _userAvatar;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String get userName => _userName ?? 'Mahasiswa IT';
  String get userEmail => _userEmail ?? '';
  String? get userAvatar => _userAvatar;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userAvatar = prefs.getString('user_avatar');
    notifyListeners();
  }

  Future<void> updateLocalName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newName);
    _userName = newName;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final result = await _authService.login(email: email, password: password);
    if (result['success'] == true) {
      await _loadSession(); // refresh token & user data
    }
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in dibatalkan oleh pengguna'};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {'success': false, 'message': 'Gagal mendapatkan ID Token Google'};
      }

      // Send the token to backend
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

  Future<Map<String, dynamic>> register({required String name, required String email, required String password, required String passwordConfirmation}) async {
    final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation);
    // registration does not log in automatically
    return result;
  }

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
