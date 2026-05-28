import '../models/mahasiswa.dart';
import '../models/absensi.dart';
import 'api_service.dart';

class MahasiswaService {
  // Ambil data mahasiswa berdasarkan id pengguna
  // Sesuai class diagram: getMahasiswa -> getData
  Future<Mahasiswa?> getData(int idPengguna) async {
    final data = await ApiService.get('mahasiswa/$idPengguna');
    if (data['success']) return Mahasiswa.fromJson(data['data']);
    return null;
  }

  // Cek total jam alpha mahasiswa
  // Sesuai class diagram: cekJamAlpha(): array
  Future<List<dynamic>> cekJamAlpha(int idMahasiswa) async {
    final data = await ApiService.get('mahasiswa/$idMahasiswa/jam-alpha');
    return data['data'] ?? [];
  }

  // Ambil semua absensi milik mahasiswa
  // Sesuai class diagram: getDetailAbsensi(id_absensi: int): object
  Future<Absensi?> getDetailAbsensi(int idAbsensi) async {
    final data = await ApiService.get('absensi/$idAbsensi');
    if (data['success']) return Absensi.fromJson(data['data']);
    return null;
  }

  // Cek apakah NIM sudah terdaftar
  // Sesuai class diagram: isRegistered(nim: String): bool
  Future<bool> isRegistered(String nim) async {
    final data = await ApiService.get('mahasiswa/check-nim/$nim');
    return data['is_registered'] ?? false;
  }
}
