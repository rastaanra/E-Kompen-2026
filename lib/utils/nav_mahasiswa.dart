import 'package:flutter/material.dart';
import '../views/mahasiswa/home_screen.dart';
import '../views/mahasiswa/pengajuan_screen.dart';
import '../views/mahasiswa/tracking_screen.dart';
import '../views/mahasiswa/profile_screen.dart';
import '../widgets/mahasiswa/app_bottom_nav.dart';
class NavMahasiswa {
  static void toHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  static void toPengajuan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PengajuanKompenScreen()),
    );
  }

  static void toTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrackingScreen()),
    );
  }

  static void toProfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  static void handleBottomNav(BuildContext context, NavTab tab, NavTab activeTab) {
    if (tab == activeTab) return;
    switch (tab) {
      case NavTab.home:
        toHome(context);
        break;
      case NavTab.pengajuan:
        toPengajuan(context);
        break;
      case NavTab.tracking:
        toTracking(context);
        break;
      case NavTab.profil:
        toProfil(context);
        break;
    }
  }
}
