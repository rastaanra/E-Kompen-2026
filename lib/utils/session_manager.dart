import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Simpan semua data setelah login
  static Future<void> simpanLogin(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Data pengguna umum
    prefs.setInt('id_pengguna', response['data']['id_pengguna']);
    prefs.setString('nama_lengkap', response['data']['nama_lengkap']);
    prefs.setString('email', response['data']['email']);
    prefs.setString('foto_profil', response['data']['foto_profil'] ?? '');
    prefs.setString('role', response['role']);

    // Data sesuai role
    if (response['role'] == 'mahasiswa') {
      prefs.setInt('id_mahasiswa', response['role_data']['id_mahasiswa']);
      prefs.setString('nim', response['role_data']['nim']);
      // 🟢 Pastikan mengambil key yang tepat dari response API (misal: 'program_studi')
      prefs.setString('program_studi', response['role_data']['program_studi'] ?? '-');
    } else if (response['role'] == 'dosen' || response['role'] == 'kaprodi') {
      prefs.setInt('id_dosen', response['role_data']['id_dosen']);
      prefs.setString('nip', response['role_data']['nip']);
    } else if (response['role'] == 'admin') {
      prefs.setInt('id_admin', response['role_data']['id_admin']);
    }
  }

  // 🟢 TAMBAHKAN GETTER RESMI INI DI DALAM CLASS SESSIONMANAGER
  static Future<String?> getProgramStudi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('program_studi');
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

  static Future<String?> getNamaLengkap() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama_lengkap');
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<String?> getNip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nip');
  }

  static Future<void> setNotifikasiAktif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifikasi_aktif', value);
  }

  static Future<bool> getNotifikasiAktif() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifikasi_aktif') ?? true;
  }

  // Set nama baru setelah update profil sukses
  static Future<void> setNamaLengkap(String namaBaru) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_lengkap', namaBaru);
  }

  // 🟢 TAMBAHAN BARU: Menyimpan URL foto profil terbaru
  static Future<void> setFotoProfil(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('foto_profil', newUrl);
  }

  // 🟢 TAMBAHAN BARU: Mengambil URL foto profil untuk UI
  static Future<String?> getFotoProfil() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('foto_profil');
  }
}