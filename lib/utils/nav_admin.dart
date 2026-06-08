import 'package:flutter/material.dart';
import '../views/admin/home_screen.dart';
import '../views/admin/pengajuan_screen.dart';
import '../views/admin/verifikasi_screen.dart';
import '../views/admin/management_screen.dart';
import '../views/admin/profile_screen.dart';
import '../views/login/login_screen.dart';
import '../widgets/admin/app_bottom_nav_admin.dart';
import '../../utils/nav_admin.dart';

class NavAdmin {
  static void toHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
    );
  }

  static void toPengajuan(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminPengajuanScreen()),
    );
  }

  static void toVerifikasi(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminVerifikasiScreen()),
    );
  }

  static void toManagement(BuildContext context, {int initialTab = -1}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminManagementScreen(initialTab: initialTab),
      ),
    );
  }

  static void toProfil(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
    );
  }

  static void toLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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