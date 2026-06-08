import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../services/mahasiswa_service.dart';

class AdminMahasiswaProvider extends ChangeNotifier {
  final MahasiswaService _service = MahasiswaService();

  List<Mahasiswa> _listMahasiswa = [];
  List<Mahasiswa> _filteredList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Filter state
  String _searchKeyword = '';
  String? _filterProdi;
  String? _filterAngkatan;

  // Getters
  List<Mahasiswa> get listMahasiswa => _filteredList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get searchKeyword => _searchKeyword;
  String? get filterProdi => _filterProdi;
  String? get filterAngkatan => _filterAngkatan;

  // Ambil semua mahasiswa
  Future<void> getAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listMahasiswa = await _service.getAll();
      _applyFilter();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Cari mahasiswa
  Future<void> cari(String keyword) async {
    _searchKeyword = keyword;

    if (keyword.isEmpty) {
      _applyFilter();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredList = await _service.cari(keyword);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set filter prodi
  void setFilterProdi(String? prodi) {
    _filterProdi = prodi;
    _applyFilter();
    notifyListeners();
  }

  // Set filter angkatan
  void setFilterAngkatan(String? angkatan) {
    _filterAngkatan = angkatan;
    _applyFilter();
    notifyListeners();
  }

  // Apply filter lokal
  void _applyFilter() {
    _filteredList = _listMahasiswa.where((mhs) {
      final prodiMatch =
          _filterProdi == null || _filterProdi!.isEmpty || mhs.programStudi == _filterProdi;
      final angkatanMatch =
          _filterAngkatan == null || _filterAngkatan!.isEmpty || mhs.nim.startsWith(_filterAngkatan!);
      return prodiMatch && angkatanMatch;
    }).toList();
  }

  // Tambah mahasiswa
  Future<bool> tambah(String nim, String nama, String programStudi) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _service.tambah({
      'nim': nim,
      'nama_lengkap': nama,
      'program_studi': programStudi,
    });

    _isLoading = false;

    if (result['success'] == true) {
      _successMessage = result['message'] ?? 'Mahasiswa berhasil ditambahkan';
      await getAll();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal menambahkan mahasiswa';
      notifyListeners();
      return false;
    }
  }

  // Edit mahasiswa
  Future<bool> edit(int id, String nama, String programStudi) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _service.edit(id, {
      'nama_lengkap': nama,
      'program_studi': programStudi,
    });

    _isLoading = false;

    if (result['success'] == true) {
      _successMessage = result['message'] ?? 'Data berhasil diubah';
      await getAll();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Gagal mengubah data mahasiswa';
      notifyListeners();
      return false;
    }
  }

  // Hapus mahasiswa
  Future<bool> hapus(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _service.hapus(id);
    _isLoading = false;

    if (success) {
      _listMahasiswa.removeWhere((m) => m.idMahasiswa == id);
      _applyFilter();
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Gagal menghapus mahasiswa';
      notifyListeners();
      return false;
    }
  }

  // Import file
  Future<bool> importFile(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _service.importFile(filePath);
    _isLoading = false;

    if (result['success'] == true) {
      _successMessage = result['message'] ?? 'Import berhasil';
      await getAll();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Import gagal';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void resetFilter() {
    _searchKeyword = '';
    _filterProdi = null;
    _filterAngkatan = null;
    _applyFilter();
    notifyListeners();
  }
}
