import 'package:flutter/material.dart';
import '../models/notifikasi.dart';
import '../services/notifikasi_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  final NotifikasiService _service = NotifikasiService();

  List<Notifikasi> _listNotifikasi = [];
  bool _isLoading = false;

  List<Notifikasi> get listNotifikasi => _listNotifikasi;
  int get jumlahBelumBaca => _listNotifikasi.length;
  bool get isLoading => _isLoading;

  // Ambil semua notifikasi
  Future<void> getNotifikasi(int idPengguna) async {
    _isLoading = true;
    notifyListeners();

    _listNotifikasi = await _service.getNotifikasi(idPengguna);

    _isLoading = false;
    notifyListeners();
  }

  // Kirim notifikasi
  Future<bool> kirimNotifikasi(Map<String, dynamic> data) async {
    return await _service.kirimNotifikasi(data);
  }
}
