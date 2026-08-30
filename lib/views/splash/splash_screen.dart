import 'package:flutter/material.dart';
import '../../utils/session_manager.dart';

import '../login/login_screen.dart';
import '../mahasiswa/home_screen.dart';
import '../dosen/home_screen.dart';
import '../kaprodi/home_screen.dart';
import '../admin/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Splash tampil 3 detik
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = await SessionManager.isLoggedIn();

    if (!mounted) return;

    // Belum login
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    // Sudah login → cek role
    final role = await SessionManager.getRole();

    if (!mounted) return;

    switch (role) {
      case 'mahasiswa':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
        break;

      case 'dosen':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DosenHomeScreen(),
          ),
        );
        break;

      case 'kaprodi':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const KaprodiHomeScreen(),
          ),
        );
        break;

      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminHomeScreen(),
          ),
        );
        break;

      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB71C1C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.school,
                size: 80,
                color: Color(0xFFB71C1C),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'E-Kompen JTI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Jurusan Teknologi Informasi',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 40),

            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}