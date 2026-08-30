import 'dart:io'; // 🟢 Tambahan wajib untuk mengurus file gambar
import 'package:flutter/material.dart';
import '../models/pengguna.dart';
import '../services/auth_service.dart';
import '../utils/session_manager.dart';

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

      print("DATA LOGIN = ${result['data']}");
      print("PASSWORD = ${result['data']['password']}");
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

    final Map<String, dynamic> result = await _service.register(data);

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

  // Update profil — Menggunakan SessionManager agar ID selalu valid & tidak null
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int? idPenggunaSesi = await SessionManager.getIdPengguna();
      
      if (idPenggunaSesi == null) {
        _isLoading = false;
        _errorMessage = 'Sesi habis, silakan login ulang';
        notifyListeners();
        return false;
      }

      if (_pengguna?.fotoProfil != null && _pengguna!.fotoProfil!.isNotEmpty) {
        data.remove('foto_profil');
      }

      final Map<String, dynamic> result = await _service.updateProfile(
        idPengguna: idPenggunaSesi,
        data: data,
      );

      _isLoading = false;

      if (result['success'] == true) {
        if (result['data'] != null) {
          _pengguna = Pengguna.fromJson(result['data']);
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal memperbarui profil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem: $e';
      notifyListeners();
      return false;
    }
  }

  // 🟢 FUNGSI BARU: Mengirim file foto profil ke backend Laravel (Sekali Pakai)
  Future<bool> uploadFotoProfilOnce(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil ID Pengguna dari SessionManager HP
      final int? idPenggunaSesi = await SessionManager.getIdPengguna();
      
      if (idPenggunaSesi == null) {
        _isLoading = false;
        _errorMessage = 'Sesi habis, silakan login ulang';
        notifyListeners();
        return false;
      }

      // 2. Kirim Multipart Request ke AuthService
      final Map<String, dynamic> result = await _service.updateProfileFotoKaprodi(
        idPengguna: idPenggunaSesi,
        imageFile: imageFile,
      );

      _isLoading = false;

      if (result['success'] == true) {
        // 3. Update data objek _pengguna lokal jika backend mengembalikan data terbaru
        if (result['data'] != null) {
          _pengguna = Pengguna.fromJson(result['data']);
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengunggah foto profil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan sistem upload foto: $e';
      notifyListeners();
      return false;
    }
  }
}