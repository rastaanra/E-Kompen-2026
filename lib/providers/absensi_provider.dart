import 'package:flutter/material.dart';
import '../models/absensi.dart';
import '../services/absensi_service.dart';

class AbsensiProvider extends ChangeNotifier {
  final AbsensiService _service = AbsensiService();

  List<Absensi> _listAbsensi = [];
  List<Absensi> _hasilCari = [];
  bool _isLoading = false;

  List<Absensi> get listAbsensi => _listAbsensi;
  List<Absensi> get hasilCari => _hasilCari;
  bool get isLoading => _isLoading;

  // Ambil semua absensi
  Future<void> getAllAbsensi(int idMahasiswa) async {
    _isLoading = true;
    notifyListeners();

    _listAbsensi = await _service.getAllAbsensi(idMahasiswa);

    _isLoading = false;
    notifyListeners();
  }

  // Cari absensi
  Future<void> cariAbsensi(String keyword) async {
    _isLoading = true;
    notifyListeners();

    _hasilCari = await _service.cariAbsensi(keyword);

    _isLoading = false;
    notifyListeners();
  }

  // Update status absensi
  Future<bool> updateStatus(int idAbsensi, String status, String keterangan) async {
    return await _service.updateStatus(idAbsensi, status, keterangan);
  }

  // Kurangi jam alpha
  Future<bool> kurangiJamAlpha(int idAbsensi, int jam) async {
    return await _service.kurangiJamAlpha(idAbsensi, jam);
  }
}
