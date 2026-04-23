import 'package:flutter/material.dart';
import '../screens/dosen/home_screen.dart';
import '../screens/dosen/pengajuan_screen.dart';
import '../screens/dosen/verifikasi_screen.dart';
import '../screens/dosen/profile_screen.dart';
import '../widgets/dosen/app_bottom_nav_dosen.dart';

class NavDosen {
  static void toHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DosenHomeScreen()),
    );
  }

  static void toPengajuan(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DosenPengajuanScreen()),
    );
  }

  static void toVerifikasi(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DosenVerifikasiScreen()),
    );
  }

  static void toProfil(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ProfileDosenScreen()),
    );
  }

  static void handleBottomNav(BuildContext context, NavTabDosen tab, NavTabDosen activeTab) {
    if (tab == activeTab) return;
    switch (tab) {
      case NavTabDosen.home:
        toHome(context);
        break;
      case NavTabDosen.pengajuan:
        toPengajuan(context);
        break;
      case NavTabDosen.verifikasi:
        toVerifikasi(context);
        break;
      case NavTabDosen.profil:
        toProfil(context);
        break;
    }
  }
}
