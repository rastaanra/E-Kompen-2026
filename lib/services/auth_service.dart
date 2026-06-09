import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  // Login pengguna
  // Sesuai class diagram: login(email: String, password: String): bool
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await ApiService.post('auth/login', {
      'email': email,
      'password': password,
    });
  }

  // Logout pengguna
  // Sesuai class diagram: logout(): void
  Future<void> logout() async {
    await ApiService.post('auth/logout', {});
  }

  // Reset password
  // Sesuai class diagram: resetPassword(email: String): bool
  Future<bool> resetPassword(String email) async {
    final data = await ApiService.post('auth/reset-password', {
      'email': email,
    });
    return data['success'] ?? false;
  }

  // Update profil pengguna (Tetap dipertahankan untuk ganti nama teks biasa)
  // Sesuai class diagram: updateProfile(data: Map): bool
  Future<Map<String, dynamic>> updateProfile({
    required int idPengguna,
    required Map<String, dynamic> data,
  }) async {
    return await ApiService.put(
      'auth/update-profile/$idPengguna',
      data,
    );
  }

  // 🟢 FUNGSI BARU: Khusus upload file foto profil Kaprodi (Hanya Sekali)
  Future<Map<String, dynamic>> updateProfileFotoKaprodi({
    required int idPengguna,
    required File imageFile,
  }) async {
    try {
      // ⚠️ CATATAN: Sesuaikan IP base URL ini dengan alamat API backend Laravel kamu ya!
      // Kalau pakai emulator Android biasanya: http://10.0.2.2:8000/api/...
      var uri = Uri.parse("http://10.0.2.2:8000/api/auth/update-profile/$idPengguna");
      
      var request = http.MultipartRequest('POST', uri);

      // Trik manipulasi agar API Route PUT di Laravel mau membaca kiriman Multipart
      request.fields['_method'] = 'PUT';

      // Bungkus file gambar lalu masukkan ke dalam key field 'foto_profil'
      request.files.add(
        await http.MultipartFile.fromPath('foto_profil', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Gagal mengunggah foto ke server (${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan upload foto: $e'
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required int idPengguna,
    required String oldPassword,
    required String newPassword,
  }) async {
    return await ApiService.post(
      'auth/change-password/$idPengguna',
      {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  // Register akun baru
  // Sesuai class diagram: register(data: Map): bool
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return await ApiService.post('auth/register', data);
  }
}