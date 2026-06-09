import '../models/pengajuan_kompen.dart';
import '../models/bukti_kompen.dart';
import '../models/riwayat_kompen.dart';
import '../models/mata_kuliah.dart';
import '../models/dosen.dart';
import '../models/admin.dart';
import 'api_service.dart';

class PengajuanService {
  // Simpan pengajuan baru
  // Sesuai class diagram: simpanPengajuan(data: Map): bool
  Future<bool> simpanPengajuan(Map<String, dynamic> data) async {
  final result = await ApiService.post(
    'pengajuan-kompen',
    data,
  );

  print(result);

  return result['success'] ?? false;
}

  // Update status pengajuan
  // Sesuai class diagram: updateStatus(id_pengajuan: int, status: String): bool
  Future<bool> updateStatus(int idPengajuan, String status) async {
    final result = await ApiService.put('pengajuan-kompen/$idPengajuan/status', {
      'status': status,
    });
    return result['success'] ?? false;
  }

  // Ambil detail satu pengajuan
  // Sesuai class diagram: getPengajuan(id_pengajuan: int): object
  Future<PengajuanKompen?> getPengajuan(int idPengajuan) async {
    final data = await ApiService.get('pengajuan-kompen/$idPengajuan');
    if (data['success']) return PengajuanKompen.fromJson(data['data']);
    return null;
  }

  // Ambil semua pengajuan milik mahasiswa
  // Sesuai class diagram: getAllPengajuan(id_mahasiswa: int): array
Future<List<PengajuanKompen>> getAllPengajuan(int idMahasiswa) async {
  final data = await ApiService.get(
    'pengajuan-kompen/mahasiswa/$idMahasiswa',
  );

  print('GET DATA:');
  print(data);

  if (data['success']) {
    return (data['data'] as List)
        .map((item) => PengajuanKompen.fromJson(item))
        .toList();
  }

  return [];
}

Future<List<PengajuanKompen>> getPengajuanAdmin(int idAdmin) async {
  final data = await ApiService.get(
    'pengajuan-kompen/admin/$idAdmin',
  );

  if (data['success']) {
    return (data['data'] as List)
        .map((item) => PengajuanKompen.fromJson(item))
        .toList();
  }

  return [];
}

Future<List<PengajuanKompen>> getPengajuanDosen(int idDosen) async {
  final data = await ApiService.get(
    'pengajuan-kompen/dosen/$idDosen',
  );

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
    final result = await ApiService.put('pengajuan-kompen/$idPengajuan/lokasi', {
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

  // Ajukan TTD — ubah status ke menunggu_ttd_dosen / menunggu_ttd_admin
  Future<bool> ajukanTTD(int idPengajuan) async {
    final result = await ApiService.post(
      'pengajuan-kompen/$idPengajuan/ajukan-ttd',
      {},
    );
    return result['success'] == true;
  }
 
  // Update deskripsi tugas + lokasi setelah pengajuan diterima
  Future<bool> updateDeskripsiLokasi(
    int idPengajuan, {
    required String deskripsi,
    required String namaLokasi,
    required double latitude,
    required double longitude,
  }) async {

    print("===== MASUK SERVICE =====");

    final result = await ApiService.put(
      'pengajuan-kompen/$idPengajuan/lengkapi',
      {
        'deskripsi_tugas': deskripsi,
        'nama_lokasi': namaLokasi,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    print("===== HASIL API =====");
    print(result);

    return result['success'] == true;
  }

  Future<List<MataKuliah>> getMataKuliah(int idMahasiswa) async {
    final data = await ApiService.get(
      'mata-kuliah/$idMahasiswa',
    );

    if (data['success']) {
      return (data['data'] as List)
          .map((item) => MataKuliah.fromJson(item))
          .toList();
    }

    return [];
  }
  

  Future<List<Dosen>> getDosen() async {
    final data = await ApiService.get('dosen');

    if (data['success']) {
      return (data['data'] as List)
          .map((item) => Dosen.fromJson(item))
          .toList();
    }

    return [];
  }

  Future<Admin?> getAdmin() async {
    final data = await ApiService.get('admin');
    print('ADMIN RESPONSE: $data'); // tambah ini
    
    if (data['success']) {
      return Admin.fromJson(data['data']);
    }

    return null;
  }

  Future<bool> ttdAdmin(int idPengajuan) async {
    final result = await ApiService.put(
      'pengajuan-kompen/$idPengajuan/ttd-admin',
      {},
    );

    return result['success'] == true;
  }
    Future<List<dynamic>> getTtdByPengajuan(int idPengajuan) async {
    final result = await ApiService.get(
      'ttd/$idPengajuan',
    );

    return result['data'] ?? [];
  }

  Future<Map<String, dynamic>?> getKaprodi() async {
    final data = await ApiService.get('kaprodi');

    if (data['success']) {
      return data['data'];
    }

    return null;
  }
}
