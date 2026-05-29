import '../models/pengajuan_kompen.dart';
import '../models/bukti_kompen.dart';
import '../models/riwayat_kompen.dart';
import 'api_service.dart';

class PengajuanService {
  // Simpan pengajuan baru
  // Sesuai class diagram: simpanPengajuan(data: Map): bool
  Future<bool> simpanPengajuan(Map<String, dynamic> data) async {
    final result = await ApiService.post('pengajuan', data);
    return result['success'] ?? false;
  }

  // Update status pengajuan
  // Sesuai class diagram: updateStatus(id_pengajuan: int, status: String): bool
  Future<bool> updateStatus(int idPengajuan, String status) async {
    final result = await ApiService.put('pengajuan/$idPengajuan/status', {
      'status': status,
    });
    return result['success'] ?? false;
  }

  // Ambil detail satu pengajuan
  // Sesuai class diagram: getPengajuan(id_pengajuan: int): object
  Future<PengajuanKompen?> getPengajuan(int idPengajuan) async {
    final data = await ApiService.get('pengajuan/$idPengajuan');
    if (data['success']) return PengajuanKompen.fromJson(data['data']);
    return null;
  }

  // Ambil semua pengajuan milik mahasiswa
  // Sesuai class diagram: getAllPengajuan(id_mahasiswa: int): array
  Future<List<PengajuanKompen>> getAllPengajuan(int idMahasiswa) async {
    final data = await ApiService.get('pengajuan/mahasiswa/$idMahasiswa');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => PengajuanKompen.fromJson(item))
          .toList();
    }
    return [];
  }

  // Update lokasi pengerjaan kompen
  // Sesuai class diagram: setLokasi / updateLokasi
  Future<bool> updateLokasi(int idPengajuan, double lat, double long, String namaLokasi) async {
    final result = await ApiService.put('pengajuan/$idPengajuan/lokasi', {
      'latitude': lat,
      'longitude': long,
      'nama_lokasi': namaLokasi,
    });
    return result['success'] ?? false;
  }

  // Generate bukti kompen PDF
  // Sesuai class diagram: generateBukti(id_pengajuan: int): file
  Future<BuktiKompen?> generateBukti(int idPengajuan) async {
    final data = await ApiService.post('pengajuan/$idPengajuan/generate-bukti', {});
    if (data['success']) return BuktiKompen.fromJson(data['data']);
    return null;
  }

  // Ambil riwayat tracking pengajuan
  // Sesuai class diagram: getRiwayat(id_pengajuan: int): array
  Future<List<RiwayatKompen>> getRiwayat(int idPengajuan) async {
    final data = await ApiService.get('pengajuan/$idPengajuan/riwayat');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => RiwayatKompen.fromJson(item))
          .toList();
    }
    return [];
  }
}
