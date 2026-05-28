import '../models/notifikasi.dart';
import 'api_service.dart';

class NotifikasiService {
  // Kirim notifikasi
  // Sesuai class diagram: kirimNotifikasi(data: Map): bool
  Future<bool> kirimNotifikasi(Map<String, dynamic> data) async {
    final result = await ApiService.post('notifikasi', data);
    return result['success'] ?? false;
  }

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
}
