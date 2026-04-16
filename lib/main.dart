import 'package:flutter/material.dart';
import 'package:tugas4_pm/screens/login/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'screens/login/login_screen.dart';
import 'screens/dosen/home_screen.dart';

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
      home: const LoginScreen(),
    );
  }
}