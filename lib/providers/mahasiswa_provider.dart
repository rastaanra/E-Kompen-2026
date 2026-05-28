import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../models/absensi.dart';
import '../services/mahasiswa_service.dart';
import '../services/absensi_service.dart';

class MahasiswaProvider extends ChangeNotifier {
  final MahasiswaService _mahasiswaService = MahasiswaService();
  final AbsensiService _absensiService = AbsensiService();

  Mahasiswa? _mahasiswa;
  List<Absensi> _listAbsensi = [];
  bool _isLoading = false;
  String? _errorMessage;

  Mahasiswa? get mahasiswa => _mahasiswa;
  List<Absensi> get listAbsensi => _listAbsensi;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ambil data mahasiswa
  Future<void> getData(int idPengguna) async {
    _isLoading = true;
    notifyListeners();

    _mahasiswa = await _mahasiswaService.getData(idPengguna);

    _isLoading = false;
    notifyListeners();
  }

  // Ambil semua absensi mahasiswa
  Future<void> getAbsensi(int idMahasiswa) async {
    _isLoading = true;
    notifyListeners();

    _listAbsensi = await _absensiService.getAllAbsensi(idMahasiswa);

    _isLoading = false;
    notifyListeners();
  }

  // Cek jam alpha
  Future<List<dynamic>> cekJamAlpha(int idMahasiswa) async {
    return await _mahasiswaService.cekJamAlpha(idMahasiswa);
  }
}
