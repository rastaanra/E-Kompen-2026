import 'package:flutter/material.dart';
import '../views/admin/home_screen.dart';
import '../views/admin/management_view.dart';
import '../widgets/admin/app_bottom_nav_admin.dart';

// TODO: import ini kalau udah dibuat
// import '../views/admin/pengajuan_screen.dart';
// import '../views/admin/profile_screen.dart';

class NavAdmin {
  static void toHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
    );
  }

  static void toPengajuan(BuildContext context) {
    // TODO: ganti Placeholder dengan AdminPengajuanScreen()
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Placeholder()),
    );
  }

  static void toVerifikasi(BuildContext context) {
    // TODO: ganti Placeholder dengan AdminVerifikasiScreen()
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Placeholder()),
    );
  }

  static void toManagement(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ManagementView()),
    );
  }

  static void toProfil(BuildContext context) {
    // TODO: ganti Placeholder dengan AdminProfileScreen()
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Placeholder()),
    );
  }

  static void handleBottomNav(
    BuildContext context,
    NavTabAdmin tab,
    NavTabAdmin activeTab,
  ) {
    if (tab == activeTab) return;
    switch (tab) {
      case NavTabAdmin.home:
        toHome(context);
        break;
      case NavTabAdmin.pengajuan:
        toPengajuan(context);
        break;
      case NavTabAdmin.verifikasi:
        toVerifikasi(context);
        break;
      case NavTabAdmin.management:
        toManagement(context);
        break;
      case NavTabAdmin.profil:
        toProfil(context);
        break;
    }
  }
}
