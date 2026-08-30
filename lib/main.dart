import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/mahasiswa_provider.dart';
import 'providers/pengajuan_provider.dart';
import 'providers/dosen_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/absensi_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/admin_mahasiswa_provider.dart';

import 'theme/app_theme.dart';

import 'views/splash/splash_screen.dart';
import 'views/login/login_screen.dart';
import 'views/mahasiswa/home_screen.dart';
import 'views/dosen/home_screen.dart';
import 'views/kaprodi/home_screen.dart';
import 'views/admin/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KompenApp());
}

class KompenApp extends StatelessWidget {
  const KompenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MahasiswaProvider()),
        ChangeNotifierProvider(create: (_) => PengajuanProvider()),
        ChangeNotifierProvider(create: (_) => DosenProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => AbsensiProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => AdminMahasiswaProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Kompen JTI',
        theme: AppTheme.theme,

        home: const SplashScreen(),

        routes: {
          '/login': (context) => const LoginScreen(),

          '/mahasiswa/dashboard': (context) =>
              const HomeScreen(),

          '/dosen/dashboard': (context) =>
              const DosenHomeScreen(),

          '/kaprodi/dashboard': (context) =>
              const KaprodiHomeScreen(),

          '/admin/dashboard': (context) =>
              const AdminHomeScreen(),
        },
      ),
    );
  }
}