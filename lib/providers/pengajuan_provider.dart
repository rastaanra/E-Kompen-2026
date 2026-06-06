import 'package:flutter/material.dart';
import '../models/pengajuan_kompen.dart';
import '../models/riwayat_kompen.dart';
import '../services/pengajuan_service.dart';
import '../models/mata_kuliah.dart';
import '../models/dosen.dart';
import '../models/admin.dart';

class PengajuanProvider extends ChangeNotifier {
  final PengajuanService _service = PengajuanService();

  List<PengajuanKompen> _listPengajuan = [];
  PengajuanKompen? _detailPengajuan;
  List<RiwayatKompen> _riwayat = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PengajuanKompen> get listPengajuan => _listPengajuan;
  PengajuanKompen? get detailPengajuan => _detailPengajuan;
  List<RiwayatKompen> get riwayat => _riwayat;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MataKuliah> _mataKuliah = [];
  List<MataKuliah> get mataKuliah => _mataKuliah;

  Future<void> getMataKuliah(int idMahasiswa) async {
    _isLoading = true;
    notifyListeners();

    _mataKuliah =
        await _service.getMataKuliah(idMahasiswa);

    _isLoading = false;
    notifyListeners();
  }

  List<Dosen> _dosen = [];
  List<Dosen> get dosen => _dosen;

  Future<void> getDosen() async {
    _isLoading = true;
    notifyListeners();

    _dosen = await _service.getDosen();

    _isLoading = false;
    notifyListeners();
  }

  Admin? _admin;
  Admin? get admin => _admin;

  Future<void> getAdmin() async {
  _admin = await _service.getAdmin();
  notifyListeners();
}

    // Ambil semua pengajuan mahasiswa
    Future<void> getAllPengajuan(int idMahasiswa) async {
      _isLoading = true;
      notifyListeners();

      _listPengajuan = await _service.getAllPengajuan(idMahasiswa);

      _isLoading = false;
      notifyListeners();
    }

  // Ambil detail pengajuan
  Future<void> getPengajuan(int idPengajuan) async {
    _isLoading = true;
    notifyListeners();

    _detailPengajuan = await _service.getPengajuan(idPengajuan);

    _isLoading = false;
    notifyListeners();
  }

  // Kirim pengajuan baru
  Future<bool> simpanPengajuan(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.simpanPengajuan(data);

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Update lokasi pengerjaan
  Future<bool> updateLokasi(int idPengajuan, double lat, double long, String namaLokasi) async {
    return await _service.updateLokasi(idPengajuan, lat, long, namaLokasi);
  }

  // Ambil riwayat tracking
  Future<void> getRiwayat(int idPengajuan) async {
    _isLoading = true;
    notifyListeners();

    _riwayat = await _service.getRiwayat(idPengajuan);

    _isLoading = false;
    notifyListeners();
  }

  // Ajukan TTD
  Future<bool> ajukanTTD(int idPengajuan) async {
    _isLoading = true;
    notifyListeners();
 
    final success = await _service.ajukanTTD(idPengajuan);
 
    _isLoading = false;
    notifyListeners();
    return success;
  }
 
  // Update deskripsi + lokasi
  Future<bool> updateDeskripsiLokasi(
    int idPengajuan, {
    required String deskripsi,
    required String namaLokasi,
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    notifyListeners();
 
    final success = await _service.updateDeskripsiLokasi(
      idPengajuan,
      deskripsi: deskripsi,
      namaLokasi: namaLokasi,
      latitude: latitude,
      longitude: longitude,
    );
 
    _isLoading = false;
    notifyListeners();
    return success;
  }
  
}
