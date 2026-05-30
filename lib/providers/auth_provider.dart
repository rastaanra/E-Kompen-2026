import 'package:flutter/material.dart';
import '../models/pengguna.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  Pengguna? _pengguna;
  bool _isLoading = false;
  String? _errorMessage;

  Pengguna? get pengguna => _pengguna;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _pengguna != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.login(email, password);

    if (result['success']) {
      _pengguna = Pengguna.fromJson(result['data']);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'] ?? 'Login gagal';
    _isLoading = false;
    notifyListeners();
    return false;
  }

// Register
Future<bool> register(Map<String, dynamic> data) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  final result = await _service.register(data);

  _isLoading = false;

  if (result['success'] == true) {
    notifyListeners();
    return true;
  }

  _errorMessage = result['message'] ?? 'Registrasi gagal';
  notifyListeners();
  return false;
}

  // Logout
  Future<void> logout() async {
    await _service.logout();
    _pengguna = null;
    notifyListeners();
  }

  // Update profil
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.updateProfile(data);

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
