import '../models/dosen.dart';
import '../models/pengajuan_kompen.dart';
import 'api_service.dart';

class DosenService {
  // Ambil data dosen berdasarkan id pengguna
  Future<Dosen?> getData(int idPengguna) async {
    final data = await ApiService.get('dosen/$idPengguna');
    if (data['success']) return Dosen.fromJson(data['data']);
    return null;
  }

  // Ambil semua pengajuan yang masuk ke dosen
  // Sesuai class diagram: getAllDosen(): array
  Future<List<PengajuanKompen>> getPengajuan(int idDosen) async {
    final data = await ApiService.get('dosen/$idDosen/pengajuan');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => PengajuanKompen.fromJson(item))
          .toList();
    }
    return [];
  }

  // Filter pengajuan berdasarkan semester atau status
  // Sesuai class diagram: memfilterData(filter: Map): array
  Future<List<PengajuanKompen>> memfilterData(Map<String, dynamic> filter) async {
    final query = filter.entries.map((e) => '${e.key}=${e.value}').join('&');
    final data = await ApiService.get('dosen/pengajuan/filter?$query');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => PengajuanKompen.fromJson(item))
          .toList();
    }
    return [];
  }

  // Konfirmasi pengajuan kompen
  // Sesuai class diagram: konfirmasiPengajuan(id_pengajuan: int): bool
  Future<bool> konfirmasiPengajuan(int idPengajuan) async {
    final result = await ApiService.put('pengajuan/$idPengajuan/konfirmasi', {});
    return result['success'] ?? false;
  }

  // Melakukan TTD digital
  // Sesuai class diagram: melakukanTTD(id_pengajuan: int): bool
  Future<bool> melakukanTTD(int idPengajuan) async {
    final result = await ApiService.post('ttd/$idPengajuan', {
      'role_ttd': 'dosen',
    });
    return result['success'] ?? false;
  }

  // Validasi akhir khusus Kaprodi
  // Sesuai class diagram: validasiAkhir(filter: Map): array
  Future<List<PengajuanKompen>> validasiAkhir(Map<String, dynamic> filter) async {
    final query = filter.entries.map((e) => '${e.key}=${e.value}').join('&');
    final data = await ApiService.get('kaprodi/validasi?$query');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => PengajuanKompen.fromJson(item))
          .toList();
    }
    return [];
  }

  // Cari dosen berdasarkan nama atau NIP
  // Sesuai class diagram: cariDosen(keyword: String): array
  Future<List<Dosen>> cariDosen(String keyword) async {
    final data = await ApiService.get('dosen/cari?keyword=$keyword');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Dosen.fromJson(item))
          .toList();
    }
    return [];
  }

  // Cek apakah NIP sudah terdaftar
  // Sesuai class diagram: isRegistered(nip: String): bool
  Future<bool> isRegistered(String nip) async {
    final data = await ApiService.get('dosen/check-nip/$nip');
    return data['is_registered'] ?? false;
  }
}
