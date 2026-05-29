import 'package:flutter/material.dart';
import '../models/dosen.dart';
import '../models/pengajuan_kompen.dart';
import '../services/dosen_service.dart';

class DosenProvider extends ChangeNotifier {
  final DosenService _service = DosenService();

  Dosen? _dosen;
  List<PengajuanKompen> _listPengajuan = [];
  bool _isLoading = false;
  String? _errorMessage;

  Dosen? get dosen => _dosen;
  List<PengajuanKompen> get listPengajuan => _listPengajuan;
  bool get isLoading => _isLoading;

  // Ambil data dosen
  Future<void> getData(int idPengguna) async {
    _isLoading = true;
    notifyListeners();

    _dosen = await _service.getData(idPengguna);

    _isLoading = false;
    notifyListeners();
  }

  // Ambil semua pengajuan masuk
  Future<void> getPengajuan(int idDosen) async {
    _isLoading = true;
    notifyListeners();

    _listPengajuan = await _service.getPengajuan(idDosen);

    _isLoading = false;
    notifyListeners();
  }

  // Filter pengajuan
  Future<void> memfilterData(Map<String, dynamic> filter) async {
    _isLoading = true;
    notifyListeners();

    _listPengajuan = await _service.memfilterData(filter);

    _isLoading = false;
    notifyListeners();
  }

  // Konfirmasi pengajuan
  Future<bool> konfirmasiPengajuan(int idPengajuan) async {
    return await _service.konfirmasiPengajuan(idPengajuan);
  }

  // TTD digital
  Future<bool> melakukanTTD(int idPengajuan) async {
    return await _service.melakukanTTD(idPengajuan);
  }

  // Validasi akhir khusus Kaprodi
  Future<void> validasiAkhir(Map<String, dynamic> filter) async {
    _isLoading = true;
    notifyListeners();

    _listPengajuan = await _service.validasiAkhir(filter);

    _isLoading = false;
    notifyListeners();
  }
}
