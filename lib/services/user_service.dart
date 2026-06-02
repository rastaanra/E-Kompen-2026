import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id_pengguna': prefs.getInt('id_pengguna'),
      'nama_lengkap': prefs.getString('nama_lengkap') ?? '',
      'email': prefs.getString('email') ?? '',
      'nim': prefs.getString('nim') ?? '',
      'role': prefs.getString('role') ?? '',
    };
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int idPengguna,
    required String namaLengkap,
    required String email,
  }) async {
    return await ApiService.put(
      'auth/update-profile/$idPengguna',
      {'nama_lengkap': namaLengkap, 'email': email},
    );
  }

  static Future<void> saveUpdatedProfile({
    required String namaLengkap,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_lengkap', namaLengkap);
    await prefs.setString('email', email);
  }
}