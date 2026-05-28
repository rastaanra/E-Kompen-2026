import 'package:flutter/material.dart';
import 'package:tugas4_pm/views/login/login_screen.dart';
import 'views/home_screen.dart';
import 'theme/app_theme.dart';
import 'views/login/login_screen.dart';
import 'views/dosen/home_screen.dart';
import 'views/splash/splash_screen.dart';

void main() {
  runApp(const KompenApp());
}

class KompenApp extends StatelessWidget {
  const KompenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kompen App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}