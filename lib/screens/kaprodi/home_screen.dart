import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../widgets/dosen/app_bottom_nav_dosen.dart';

class KaprodiHomeScreen extends StatelessWidget {
  const KaprodiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Kaprodi')),
      body: const Center(
        child: Text(
          'Halaman Kaprodi\n(Coming Soon)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}