import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../models/pengajuan_kompen.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<Mahasiswa> _listMahasiswa = [];
  List<PengajuanKompen> _listPengajuan = [];
  List<dynamic> _hasilCari = [];
  bool _isLoading = false;

  List<Mahasiswa> get listMahasiswa => _listMahasiswa;
  List<PengajuanKompen> get listPengajuan => _listPengajuan;
  List<dynamic> get hasilCari => _hasilCari;
  bool get isLoading => _isLoading;

  // Ambil semua pengajuan
  Future<void> getAllPengajuan(int idAdmin) async {
    _isLoading = true;
    notifyListeners();

    _listPengajuan =
        await _service.getAllPengajuan(idAdmin);

    _isLoading = false;
    notifyListeners();
  }

  // Cari mahasiswa
  Future<void> cariMahasiswa(String keyword) async {
    _isLoading = true;
    notifyListeners();

    _listMahasiswa = await _service.cariMahasiswa(keyword);

    _isLoading = false;
    notifyListeners();
  }

  // Cari data umum
  Future<void> mencariData(String keyword, String type) async {
    _isLoading = true;
    notifyListeners();

    _hasilCari = await _service.mencariData(keyword, type);

    _isLoading = false;
    notifyListeners();
  }

  // Set kaprodi
  Future<bool> setKaprodi(int idDosen) async {
    return await _service.setKaprodi(idDosen);
  }

  // Konfirmasi pengajuan
  Future<bool> konfirmasiPengajuan(int idPengajuan) async {
    return await _service.konfirmasiPengajuan(idPengajuan);
  }

  // TTD admin
  Future<bool> melakukanTTD(int idPengajuan) async {
    return await _service.melakukanTTD(idPengajuan);
  }
}
