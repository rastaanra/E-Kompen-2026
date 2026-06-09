import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Simpan semua data setelah login
  static Future<void> simpanLogin(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    // Data pengguna
    prefs.setInt('id_pengguna', response['data']['id_pengguna']);
    prefs.setString('nama_lengkap', response['data']['nama_lengkap']);
    prefs.setString('email', response['data']['email']);
    prefs.setString('foto_profil', response['data']['foto_profil'] ?? '');

    // Role
    prefs.setString('role', response['role']);

    // Data sesuai role
    if (response['role'] == 'mahasiswa') {
      prefs.setInt('id_mahasiswa', response['role_data']['id_mahasiswa']);
      prefs.setString('nim', response['role_data']['nim']);
    } else if (response['role'] == 'dosen' || response['role'] == 'kaprodi') {
      prefs.setInt('id_dosen', response['role_data']['id_dosen']);
      prefs.setString('nip', response['role_data']['nip']); 
    } else if (response['role'] == 'admin') {
      prefs.setInt('id_admin', response['role_data']['id_admin']);
    }
  }

  // Ambil role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Ambil id pengguna
  static Future<int?> getIdPengguna() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_pengguna');
  }

  // Cek sudah login atau belum
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('role');
  }

  // Hapus session saat logout
  static Future<void> hapus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int?> getIdAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id_admin');
}

static Future<int?> getIdMahasiswa() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id_mahasiswa');
}

static Future<int?> getIdDosen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('id_dosen');
}
}