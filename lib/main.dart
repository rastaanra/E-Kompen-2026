import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';

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
      home: const LoginScreen(),
    );
  }
}