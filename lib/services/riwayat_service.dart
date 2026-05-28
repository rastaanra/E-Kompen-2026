import '../models/riwayat_kompen.dart';
import 'api_service.dart';

class RiwayatService {
  // Simpan perubahan status baru ke riwayat
  // Sesuai class diagram: simpanRiwayat(data: Map): bool
  Future<bool> simpanRiwayat(Map<String, dynamic> data) async {
    final result = await ApiService.post('riwayat', data);
    return result['success'] ?? false;
  }

  // Ambil semua riwayat perubahan status pengajuan
  // Sesuai class diagram: getRiwayat(id_pengajuan: int): array
  Future<List<RiwayatKompen>> getRiwayat(int idPengajuan) async {
    final data = await ApiService.get('riwayat/pengajuan/$idPengajuan');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => RiwayatKompen.fromJson(item))
          .toList();
    }
    return [];
  }
}
