import '../models/ttd_digital.dart';
import 'api_service.dart';

class TtdService {
  // Simpan data TTD setelah penandatangan setuju
  // Sesuai class diagram: simpanTTD(data: Map): bool
  Future<bool> simpanTTD(Map<String, dynamic> data) async {
    final result = await ApiService.post('ttd', data);
    return result['success'] ?? false;
  }

  // Verifikasi kode TTD yang diinput penandatangan
  // Sesuai class diagram: verifikasiTTD(kode: String): bool
  Future<bool> verifikasiTTD(String kode) async {
    final result = await ApiService.post('ttd/verifikasi', {
      'kode_ttd': kode,
    });
    return result['success'] ?? false;
  }

  // Minta kode TTD yang digenerate Laravel
  // Sesuai class diagram: generateKode(): String
  // CATATAN: kode digenerate di Laravel bukan Flutter, lebih aman
  Future<String?> generateKode(int idPengajuan) async {
    final data = await ApiService.post(
      'ttd/$idPengajuan/generate-kode', {});
    if (data['success']) return data['kode_ttd'];
    return null;
  }

  // Ambil semua data TTD dari satu pengajuan
  // Sesuai class diagram: getTTD(id_pengajuan: int): array
  Future<List<TtdDigital>> getTTD(int idPengajuan) async {
    final data = await ApiService.get('ttd/pengajuan/$idPengajuan');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => TtdDigital.fromJson(item))
          .toList();
    }
    return [];
  }
}