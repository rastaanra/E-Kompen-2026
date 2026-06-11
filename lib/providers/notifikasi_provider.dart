import 'package:flutter/material.dart';
import '../models/notifikasi.dart';
import '../services/notifikasi_service.dart';

class NotifikasiProvider extends ChangeNotifier {
  final NotifikasiService _service = NotifikasiService();

  List<Notifikasi> _listNotifikasi = [];
  bool _isLoading = false;

  List<Notifikasi> get listNotifikasi => _listNotifikasi;

  bool get hasUnreadNotif =>
      _listNotifikasi.any((e) => !e.sudahDilihat);

  bool get isLoading => _isLoading;

  Future<void> lihatSemua(int idPengguna) async {
    await _service.lihatSemua(idPengguna);
    await getNotifikasi(idPengguna);
  }

  Future<void> getNotifikasi(int idPengguna) async {
    _isLoading = true;
    notifyListeners();

    _listNotifikasi =
        await _service.getNotifikasi(idPengguna);

    _isLoading = false;
    notifyListeners();
  }
}