import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/absensi.dart';
import '../core/constants/api_constant.dart';
import 'api_service.dart';

class MahasiswaService {
  // ─── MAHASISWA (USER) ───────────────────────────────

  // Ambil data mahasiswa berdasarkan id pengguna
  Future<Mahasiswa?> getData(int idPengguna) async {
    final data = await ApiService.get('mahasiswa/pengguna/$idPengguna');
    if (data['success']) return Mahasiswa.fromJson(data['data']);
    return null;
  }

  // Cek total jam alpha mahasiswa
  Future<List<dynamic>> cekJamAlpha(int idMahasiswa) async {
    final data = await ApiService.get('mahasiswa/$idMahasiswa/jam-alpha');
    return data['data'] ?? [];
  }

  // Ambil detail absensi
  Future<Absensi?> getDetailAbsensi(int idAbsensi) async {
    final data = await ApiService.get('absensi/$idAbsensi');
    if (data['success']) return Absensi.fromJson(data['data']);
    return null;
  }

  // Cek apakah NIM sudah terdaftar
  Future<bool> isRegistered(String nim) async {
    final data = await ApiService.get('mahasiswa/check-nim/$nim');
    return data['is_registered'] ?? false;
  }

  // ─── ADMIN ──────────────────────────────────────────

  // GET /api/mahasiswa — ambil semua mahasiswa
  Future<List<Mahasiswa>> getAll() async {
    final data = await ApiService.get('mahasiswa');
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((item) => Mahasiswa.fromJson(item))
          .toList();
    }
    return [];
  }

  // GET /api/mahasiswa/{id} — ambil 1 mahasiswa
  Future<Mahasiswa?> getById(int id) async {
    final data = await ApiService.get('mahasiswa/$id');
    if (data['success'] == true) return Mahasiswa.fromJson(data['data']);
    return null;
  }

  // POST /api/mahasiswa — tambah mahasiswa manual
  Future<Map<String, dynamic>> tambah(Map<String, dynamic> body) async {
    return await ApiService.post('mahasiswa', body);
  }

  // PUT /api/mahasiswa/{id} — edit mahasiswa (NIM tidak bisa diubah)
  Future<Map<String, dynamic>> edit(int id, Map<String, dynamic> body) async {
    return await ApiService.put('mahasiswa/$id', body);
  }

  // DELETE /api/mahasiswa/{id} — hapus mahasiswa
  Future<bool> hapus(int id) async {
    final result = await ApiService.delete('mahasiswa/$id');
    return result['success'] == true;
  }

  // GET /api/mahasiswa/cari?keyword=xxx — cari mahasiswa
  Future<List<Mahasiswa>> cari(String keyword) async {
    final data = await ApiService.get('mahasiswa/cari?keyword=$keyword');
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((item) => Mahasiswa.fromJson(item))
          .toList();
    }
    return [];
  }

  // GET /api/mahasiswa/filter?prodi=xxx&angkatan=24 — filter mahasiswa
  Future<List<Mahasiswa>> filter({String? prodi, String? angkatan}) async {
    String query = '';
    if (prodi != null && prodi.isNotEmpty) query += 'prodi=$prodi&';
    if (angkatan != null && angkatan.isNotEmpty) query += 'angkatan=$angkatan';
    final data = await ApiService.get('mahasiswa/filter?$query');
    if (data['success'] == true) {
      return (data['data'] as List)
          .map((item) => Mahasiswa.fromJson(item))
          .toList();
    }
    return [];
  }

  // POST /api/mahasiswa/import — import file Excel/CSV
  Future<Map<String, dynamic>> importFile(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstant.baseUrl}/mahasiswa/import'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Import berhasil'};
      }
      return {'success': false, 'message': 'Import gagal'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
