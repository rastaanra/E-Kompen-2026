import '../models/bukti_kompen.dart';
import 'api_service.dart';

class BuktiService {
  // Generate file PDF bukti kompen dari data pengajuan
  // Sesuai class diagram: generatePDF(id_pengajuan: int): file
  Future<BuktiKompen?> generatePDF(int idPengajuan) async {
    final data = await ApiService.post(
      'bukti/$idPengajuan/generate', {});
    if (data['success']) return BuktiKompen.fromJson(data['data']);
    return null;
  }

  // Download file PDF bukti kompen
  // Sesuai class diagram: unduh(id_bukti: int): file
  Future<String?> unduh(int idBukti) async {
    final data = await ApiService.get('bukti/$idBukti/unduh');
    if (data['success']) return data['file_path'];
    return null;
  }

  // Ambil data bukti berdasarkan id pengajuan
  // Sesuai class diagram: getBukti(id_pengajuan: int): object
  Future<BuktiKompen?> getBukti(int idPengajuan) async {
    final data = await ApiService.get('bukti/pengajuan/$idPengajuan');
    if (data['success']) return BuktiKompen.fromJson(data['data']);
    return null;
  }
}
