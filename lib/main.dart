import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tugas4_pm/views/login/login_screen.dart';
import 'providers/auth_provider.dart';
import 'views/mahasiswa/home_screen.dart';
import 'theme/app_theme.dart';
import 'views/dosen/home_screen.dart';
import 'views/splash/splash_screen.dart';
import 'providers/mahasiswa_provider.dart';
import 'providers/pengajuan_provider.dart';
import 'providers/admin_provider.dart';

void main() {
  runApp(const KompenApp());
}

class KompenApp extends StatelessWidget {
  const KompenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
  ChangeNotifierProvider(
    create: (_) => AuthProvider(),
  ),
  ChangeNotifierProvider(
    create: (_) => MahasiswaProvider(),
  ),
  ChangeNotifierProvider(
    create: (_) => PengajuanProvider(),
  ),
  ChangeNotifierProvider(
    create: (_) => AdminProvider()
    ),
],
      child: MaterialApp(
        title: 'Kompen App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}