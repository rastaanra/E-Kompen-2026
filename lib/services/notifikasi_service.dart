import '../models/notifikasi.dart';
import 'api_service.dart';

class NotifikasiService {
  // Kirim notifikasi
  // Sesuai class diagram: kirimNotifikasi(data: Map): bool

  // Ambil semua notifikasi milik pengguna
  // Sesuai class diagram: getNotifikasi(id_pengguna: int): array
  Future<List<Notifikasi>> getNotifikasi(int idPengguna) async {
    final data = await ApiService.get('notifikasi/$idPengguna');
    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Notifikasi.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<bool> lihatSemua(int idPengguna) async {
    final result =
        await ApiService.put('notifikasi/$idPengguna/lihat', {});

    return result['success'] ?? false;
  }
}