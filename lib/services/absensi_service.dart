import '../models/absensi.dart';
import 'api_service.dart';

class AbsensiService {
  // Ambil semua absensi
  // Sesuai class diagram: getAllAbsensi(id_mahasiswa: int): array
  Future<List<Absensi>> getAllAbsensi(int idMahasiswa) async {
    final data = await ApiService.get('absensi/mahasiswa/$idMahasiswa');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Absensi.fromJson(item))
          .toList();
    }
    return [];
  }

  // Update status absensi
  // Sesuai class diagram: updateStatus(id_absensi: int, status: String): bool
  Future<bool> updateStatus(int idAbsensi, String status, String keterangan) async {
    final result = await ApiService.put('absensi/$idAbsensi/status', {
      'status': status,
      'keterangan': keterangan,
    });
    return result['success'] ?? false;
  }

  // Kurangi jam alpha setelah kompen selesai
  // Sesuai class diagram: kurangiJamAlpha(id_absensi: int, jam: int): bool
  Future<bool> kurangiJamAlpha(int idAbsensi, int jam) async {
    final result = await ApiService.put('absensi/$idAbsensi/kurangi-jam', {
      'jam': jam,
    });
    return result['success'] ?? false;
  }

  // Cari absensi berdasarkan keyword
  // Sesuai class diagram: cariAbsensi(keyword: String): array
  Future<List<Absensi>> cariAbsensi(String keyword) async {
    final data = await ApiService.get('absensi/cari?keyword=$keyword');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Absensi.fromJson(item))
          .toList();
    }
    return [];
  }

  // Filter absensi alpha
  // Sesuai class diagram: filterAlpha(): array
  Future<List<Absensi>> filterAlpha(int idMahasiswa) async {
    final data = await ApiService.get('absensi/mahasiswa/$idMahasiswa?status=alpha');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Absensi.fromJson(item))
          .toList();
    }
    return [];
  }
}
