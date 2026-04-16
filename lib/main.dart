import 'package:flutter/material.dart';
import 'package:tugas4_pm/screens/splash_screen.dart';
import 'package:tugas4_pm/screens/dosen/home_screen.dart';
import 'package:tugas4_pm/screens/dosen/pengajuan_screen.dart';
import 'package:tugas4_pm/screens/dosen/verifikasi_screen.dart';
import 'package:tugas4_pm/screens/dosen/profile_screen.dart';

void main() {
  runApp(const KompenApp());
}

class KompenApp extends StatelessWidget {
  const KompenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Kompen JTI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
      ),
      home: DosenHomeScreen(),
    );
  }
}