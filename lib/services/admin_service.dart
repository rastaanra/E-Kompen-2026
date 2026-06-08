import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/pengajuan_kompen.dart';
import 'api_service.dart';

class AdminService {
  // Import data absensi dari CSV
  // Sesuai class diagram: importDataAbsensi(file: csv): bool
  Future<bool> importDataAbsensi(String filePath) async {
    final result = await ApiService.post('admin/import-absensi', {
      'file': filePath,
    });
    return result['success'] ?? false;
  }

  // Import data mahasiswa dari CSV
  // Sesuai class diagram: importDataMahasiswa(file: csv): bool
  Future<bool> importDataMahasiswa(String filePath) async {
    final result = await ApiService.post('admin/import-mahasiswa', {
      'file': filePath,
    });
    return result['success'] ?? false;
  }

  // CRUD data mahasiswa
  // Sesuai class diagram: mengelolaDataMahasiswa(action: String, data: Map): bool
  Future<bool> mengelolaDataMahasiswa(String action, Map<String, dynamic> data) async {
    final result = await ApiService.post('admin/mahasiswa/$action', data);
    return result['success'] ?? false;
  }

  // CRUD data dosen
  // Sesuai class diagram: mengelolaDataDosen(action: String, data: Map): bool
  Future<bool> mengelolaDataDosen(String action, Map<String, dynamic> data) async {
    final result = await ApiService.post('admin/dosen/$action', data);
    return result['success'] ?? false;
  }

  // Set dosen sebagai kaprodi
  // Sesuai class diagram: setKaprodi(id_dosen: int): bool
  Future<bool> setKaprodi(int idDosen) async {
    final result = await ApiService.put('admin/dosen/$idDosen/set-kaprodi', {});
    return result['success'] ?? false;
  }

  // Konfirmasi pengajuan
  // Sesuai class diagram: konfirmasiPengajuan(id_pengajuan: int): bool
  Future<bool> konfirmasiPengajuan(int idPengajuan) async {
    final result =
        await ApiService.put(
          'pengajuan-kompen/$idPengajuan/konfirmasi',
          {},
        );

    return result['success'] ?? false;
  }
  // TTD digital admin
  // Sesuai class diagram: melakukanTTD(id_pengajuan: int): bool
  Future<bool> melakukanTTD(int idPengajuan) async {
    final result = await ApiService.post('ttd/$idPengajuan', {
      'role_ttd': 'admin',
    });
    return result['success'] ?? false;
  }

  // Filter data
  // Sesuai class diagram: memfilterData(filter: Map): array
  Future<List<dynamic>> memfilterData(Map<String, dynamic> filter) async {
    final query = filter.entries.map((e) => '${e.key}=${e.value}').join('&');
    final data = await ApiService.get('admin/filter?$query');
    return data['data'] ?? [];
  }

  // Cari data mahasiswa atau absensi
  // Sesuai class diagram: mencariData(keyword: String, type: String): array
  Future<List<dynamic>> mencariData(String keyword, String type) async {
    final data = await ApiService.get('admin/cari?keyword=$keyword&type=$type');
    return data['data'] ?? [];
  }

  // Cari mahasiswa berdasarkan nama atau NIM
  // Sesuai class diagram: cariMahasiswa(keyword: String): array
  Future<List<Mahasiswa>> cariMahasiswa(String keyword) async {
    final data = await ApiService.get('admin/mahasiswa/cari?keyword=$keyword');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Mahasiswa.fromJson(item))
          .toList();
    }
    return [];
  }

  // Ambil semua pengajuan untuk admin
Future<List<PengajuanKompen>> getAllPengajuan(int idAdmin) async {
  print("ID ADMIN = $idAdmin");

  final data =
      await ApiService.get('pengajuan-kompen/admin/$idAdmin');

  print(data);

  if (data['success']) {
    return (data['data'] as List)
        .map((item) => PengajuanKompen.fromJson(item))
        .toList();
  }

  return [];
}
}
