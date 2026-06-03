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

  // Update profil pengguna
  // Sesuai class diagram: updateProfile(data: Map): bool
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final result = await ApiService.put('auth/update-profile', data);
    return result['success'] ?? false;
  }

  // Register akun baru
  // Sesuai class diagram: register(data: Map): bool
      // SESUDAH
    Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
      return await ApiService.post('auth/register', data);
    }
}
