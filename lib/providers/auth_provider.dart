import 'package:flutter/material.dart';
import '../models/pengguna.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  Pengguna? _pengguna;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _lastResponse = {};

  Pengguna? get pengguna => _pengguna;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _pengguna != null;
  Map<String, dynamic> get lastResponse => _lastResponse;

  // Login — service return Map
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final Map<String, dynamic> result = await _service.login(email, password);
      if (result['success'] == true) {

        final userData = result['data'];

        userData['role'] = result['role'];

        _pengguna = Pengguna.fromJson(result['data']);

        _lastResponse = result;
        _isLoading = false;
        notifyListeners();
        return true;
      }

    _errorMessage = result['message'] ?? 'Login gagal';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register — service return Map
  Future<bool> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final Map<String, dynamic> result = await _service.register(data); // ✅ Map

    _isLoading = false;

    if (result['success'] != true) {
      _errorMessage = result['message'] ?? 'Registrasi gagal';
    }

    notifyListeners();
    return result['success'] == true;
  }

  // Logout
  Future<void> logout() async {
    await _service.logout();
    _pengguna = null;
    _lastResponse = {};
    notifyListeners();
  }

  // Update profil — service return bool
  // Foto profil hanya bisa dipasang sekali, tidak bisa diganti
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_pengguna?.fotoProfil != null && _pengguna!.fotoProfil!.isNotEmpty) {
      data.remove('foto_profil');
    }

    _isLoading = true;
    notifyListeners();

    final bool success = await _service.updateProfile(data);

    _isLoading = false;
    notifyListeners();
    return success;
  }
}