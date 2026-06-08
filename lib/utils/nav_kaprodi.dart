import 'package:flutter/material.dart';
import '../views/kaprodi/home_screen.dart';
import '../views/kaprodi/verifikasi_screen.dart';
import '../views/kaprodi/profile_screen.dart';
import '../views/login/login_screen.dart';
import '../widgets/kaprodi/app_bottom_nav_kaprodi.dart';

class NavKaprodi {
  static void toHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const KaprodiHomeScreen()),
    );
  }

  static void toVerifikasi(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => KaprodiVerifikasiScreen()),
    );
  }

  static void toProfil(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileKaprodiScreen()),
    );
  }

  static void toLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  static void handleBottomNav(BuildContext context, NavTabKaprodi tab, NavTabKaprodi activeTab) {
    if (tab == activeTab) return;
    switch (tab) {
      case NavTabKaprodi.home:
        toHome(context);
        break;
      case NavTabKaprodi.verifikasi:
        toVerifikasi(context);
        break;
      case NavTabKaprodi.profil:
        toProfil(context);
        break;
    }
  }
}